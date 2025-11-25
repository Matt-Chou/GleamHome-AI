import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart' as cam;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/photo_analysis.dart';
import '../models/analysis_record.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';

/// 相機屏幕 - 實時拍照和選擇照片
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  // Web/Android/iOS platform detection
  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  cam.CameraController? _cameraController; // Only for Android/iOS
  List<cam.CameraDescription>? _cameras;
  XFile? _selectedImage;
  bool _showPreview = false;
  bool _isCameraInitialized = false;
  bool _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool _isUploading = false;
  bool _isFromGallery = false; // 記錄是否從相簿選擇
  double _uploadProgress = 0.0; // 上傳進度 0.0 - 1.0
  String _uploadStatus = ''; // 上傳狀態訊息

  @override
  bool _onlyGallery = false;
  bool _autoTriggered = false;

  @override
  void initState() {
    super.initState();
    // Initialize camera only for Android/iOS
    if (_isMobile) {
      _initMobileCamera();
    }
    // 延遲觸發：根據參數自動開啟相機或相簿，且不顯示任何按鈕
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['pickGallery'] == true) {
        setState(() {
          _onlyGallery = true;
        });
        if (!_autoTriggered) {
          _autoTriggered = true;
          await _pickFromGallery();
        }
      } else {
        setState(() {
          _onlyGallery = false;
        });
        if (!_autoTriggered) {
          _autoTriggered = true;
          await _takePhoto();
        }
      }
    });
  }

  Future<void> _initMobileCamera() async {
    try {
      _cameras = await cam.availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = cam.CameraController(
          _cameras![0],
          cam.ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('圖片分析'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _showPreview && _selectedImage != null
          ? _buildPhotoPreview()
          : _buildCameraView(),
    );
  }

  /// 構建相機視圖
  Widget _buildCameraView() {
    // 平台分支：Web 使用 image_picker，Android/iOS 使用 camera
    if (kIsWeb) {
      // Web: 只能用 image_picker (無法即時預覽)
      return _buildWebCameraView();
    } else if (_isMobile) {
      // Android/iOS: 使用 camera plugin
      return _buildMobileCameraView();
    } else {
      // 其他平台 fallback
      return Center(child: Text('此平台暫不支援相機功能'));
    }
  }

  // Web 相機 UI（支援拍照與相簿上傳，無即時預覽）
  Widget _buildWebCameraView() {
    // 只顯示 loading 或預覽，不顯示任何按鈕
    if (_showPreview && _selectedImage != null) {
      return _buildPhotoPreview();
    }
    return const Center(child: CircularProgressIndicator());
  }

  // Android/iOS 相機 UI（即時預覽，支援相簿上傳）
  Widget _buildMobileCameraView() {
    // 只顯示 loading 或預覽，不顯示任何按鈕
    if (_showPreview && _selectedImage != null) {
      return _buildPhotoPreview();
    }
    return const Center(child: CircularProgressIndicator());
  }

  /// 構建照片預覽視圖
  Widget _buildPhotoPreview() {
    return Column(
      children: [
        // 照片預覽
        Expanded(
          child: Container(
            color: Colors.black,
            child: Image.file(File(_selectedImage!.path), fit: BoxFit.contain),
          ),
        ),

        // 操作欄
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 操作按鈕
              Row(
                children: [
                  // 重新拍照/重新選擇（根據來源決定）
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : () async {
                        setState(() {
                          _showPreview = false;
                          _selectedImage = null;
                        });
                        // 根據來源決定要開啟相機還是相簿
                        if (_isFromGallery) {
                          await _pickFromGallery();
                        } else {
                          await _takePhoto();
                        }
                      },
                      icon: Icon(_isFromGallery ? Icons.photo_library : Icons.camera_alt),
                      label: Text(_isFromGallery ? '重新選擇' : '重新拍照'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 上傳分析
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isUploading ? null : _uploadAndAnalyze,
                      icon: _isUploading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isUploading ? '上傳中...' : '上傳分析'),
                    ),
                  ),
                ],
              ),
              
              // 上傳進度條
              if (_isUploading) ...[
                const SizedBox(height: 12),
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _uploadStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),

              // 照片信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '照片已選擇',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            _selectedImage!.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 拍照（平台分支）
  Future<void> _takePhoto() async {
    try {
      // 統一使用 image_picker 的相機功能（支援 Android/iOS/Web）
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
          _showPreview = true;
          _isFromGallery = false; // 標記為相機來源
        });
      } else {
        // 使用者取消拍照
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('拍照錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法開啟相機: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// 從相冊選擇照片
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _showPreview = true;
          _isFromGallery = true; // 標記為相簿來源
        });
      } else {
        // 使用者取消選擇
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('選擇照片錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法存取相簿: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// 上傳影像並執行分析
  Future<void> _uploadAndAnalyze() async {
    if (_selectedImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請先登入')),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = '準備上傳...';
    });

    try {
      debugPrint('🚀 開始上傳流程...');
      
      // 1. 上傳影像到 Firebase Storage
      setState(() {
        _uploadProgress = 0.1;
        _uploadStatus = '正在上傳影像...';
      });
      
      debugPrint('📤 步驟 1: 上傳影像到 Storage');
      final file = File(_selectedImage!.path);
      final imageUrl = await _storageService.uploadImage(file, user.uid)
          .timeout(const Duration(seconds: 60), onTimeout: () {
        throw Exception('上傳超時，請檢查網路連線');
      });
      debugPrint('✅ Storage 上傳完成: $imageUrl');

      // 2. 建立分析記錄
      setState(() {
        _uploadProgress = 0.6;
        _uploadStatus = '建立分析記錄...';
      });
      
      debugPrint('📝 步驟 2: 建立分析記錄');
      final record = AnalysisRecord(
        id: '', // Firestore 會自動產生
        userId: user.uid,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        analysisResults: {
          'status': 'pending',
          'message': '分析中...',
        },
        deviceInfo: Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown',
      );

      // 3. 儲存到 Firestore
      setState(() {
        _uploadProgress = 0.8;
        _uploadStatus = '儲存到雲端...';
      });
      
      debugPrint('💾 步驟 3: 儲存到 Firestore');
      final recordId = await _firestoreService.addAnalysisRecord(record)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Firestore 儲存超時');
      });
      debugPrint('✅ Firestore 儲存完成: $recordId');

      // 完成
      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = '上傳完成！';
      });

      // 停止上傳狀態
      debugPrint('🎉 所有步驟完成，停止上傳狀態');
      await Future.delayed(const Duration(milliseconds: 500)); // 讓使用者看到 100%
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }

      if (mounted) {
        // 顯示成功對話框
        debugPrint('📢 顯示成功對話框');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  '上傳成功！',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '影像已儲存到雲端',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉對話框
                  Navigator.of(context).pop(); // 返回主畫面
                },
                child: const Text('確定'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 上傳失敗: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上傳失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

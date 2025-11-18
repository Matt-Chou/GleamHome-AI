import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart' as cam;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/photo_analysis.dart';

/// 相機屏幕 - 實時拍照和選擇照片
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  // Web/Android/iOS platform detection
  final ImagePicker _imagePicker = ImagePicker();
  cam.CameraController? _cameraController; // Only for Android/iOS
  List<cam.CameraDescription>? _cameras;
  XFile? _selectedImage;
  bool _showPreview = false;
  bool _isCameraInitialized = false;
  bool _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
        title: const Text('拍照分析'),
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
                  // 重新拍照
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPreview = false;
                          _selectedImage = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('重新拍照'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 確認繼續
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // 跳轉到照片審核頁面
                        Navigator.of(context).pushNamed(
                          '/photo-review',
                          arguments: _selectedImage?.path,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('確認'),
                    ),
                  ),
                ],
              ),
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
    if (kIsWeb) {
      // Web: 使用 image_picker
      try {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
        );
        if (photo != null) {
          setState(() {
            _selectedImage = photo;
            _showPreview = true;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Web 無法打開相機: $e')));
        }
      }
    } else if (_isMobile &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      // Android/iOS: 使用 camera plugin
      try {
        final cam.XFile photo = await _cameraController!.takePicture();
        setState(() {
          _selectedImage = XFile(photo.path);
          _showPreview = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('無法拍照: $e')));
        }
      }
    } else {
      // 其他平台或初始化失敗
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('此平台暫不支援相機功能')));
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('無法存取相冊: $e')));
      }
    }
  }
}

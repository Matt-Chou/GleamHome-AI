import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/photo_analysis.dart';

/// 相機屏幕 - 實時拍照和選擇照片
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _showPreview = false;

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
    return Column(
      children: [
        // 提示區域
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                '拍照你的房間或物品',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '拍攝清晰的照片可以獲得更準確的分析結果',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // 按鈕區域
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 拍照按鈕
              FloatingActionButton.extended(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照'),
                heroTag: 'camera_btn',
              ),
              const SizedBox(height: 24),

              // 從相冊選擇
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.image),
                label: const Text('選擇照片'),
              ),
            ],
          ),
        ),

        // 幫助提示
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '拍照提示',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                '• 確保光線充足\n'
                '• 保持相機穩定\n'
                '• 包含整個房間或物品\n'
                '• 避免過度傾斜或模糊',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 構建照片預覽視圖
  Widget _buildPhotoPreview() {
    return Column(
      children: [
        // 照片預覽
        Expanded(
          child: Container(
            color: Colors.black,
            child: Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.contain,
            ),
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

  /// 拍照
  Future<void> _takePhoto() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法打開相機: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法存取相冊: $e')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

/// 照片審核屏幕 - 預覽、編輯和確認照片
class PhotoReviewScreen extends ConsumerStatefulWidget {
  final String? photoPath;

  const PhotoReviewScreen({super.key, this.photoPath});

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  late String _currentPhotoPath;
  String _selectedRoomType = 'bedroom'; // 默認房間類型
  double _brightness = 1.0;
  bool _showBrightnessSlider = false;

  final List<String> _roomTypes = [
    'bedroom',
    'living-room',
    'kitchen',
    'bathroom',
    'closet',
    'storage',
    'office',
    'balcony',
    'other',
  ];

  final Map<String, String> _roomTypeLabels = {
    'bedroom': '臥室',
    'living-room': '客廳',
    'kitchen': '廚房',
    'bathroom': '浴室',
    'closet': '衣櫃',
    'storage': '儲藏室',
    'office': '辦公室',
    'balcony': '陽台',
    'other': '其他',
  };

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.photoPath ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('審核照片'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 照片預覽
          Expanded(
            child: Container(
              color: Colors.black,
              child: _currentPhotoPath.isNotEmpty
                  ? ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        _brightness,
                        0,
                      ]),
                      child: Image.file(
                        File(_currentPhotoPath),
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Center(child: Text('未找到照片')),
            ),
          ),

          // 亮度調整滑塊
          if (_showBrightnessSlider)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.brightness_low, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _brightness,
                          min: 0.5,
                          max: 1.5,
                          divisions: 20,
                          label: '${(_brightness * 100).toStringAsFixed(0)}%',
                          onChanged: (value) {
                            setState(() {
                              _brightness = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.brightness_high, color: Colors.grey[600]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showBrightnessSlider = false;
                        });
                      },
                      child: const Text('完成'),
                    ),
                  ),
                ],
              ),
            ),

          // 房間類型選擇
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('房間類型', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _roomTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final roomType = _roomTypes[index];
                      final isSelected = _selectedRoomType == roomType;

                      return FilterChip(
                        selected: isSelected,
                        label: Text(_roomTypeLabels[roomType]!),
                        onSelected: (selected) {
                          setState(() {
                            _selectedRoomType = roomType;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 操作按鈕
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // 信息卡片
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '本次分析將消耗約 450 tokens',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '您當前有 550 tokens 額度',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 編輯和提交按鈕
                Row(
                  children: [
                    // 調整亮度
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showBrightnessSlider = !_showBrightnessSlider;
                          });
                        },
                        icon: const Icon(Icons.brightness_5),
                        label: const Text('亮度'),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 開始分析
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _startAnalysis,
                        icon: const Icon(Icons.check),
                        label: const Text('開始分析'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startAnalysis() {
    // 導航到分析進度屏幕
    Navigator.of(context).pushNamed(
      '/analysis',
      arguments: {
        'photoPath': _currentPhotoPath,
        'roomType': _selectedRoomType,
      },
    );
  }
}

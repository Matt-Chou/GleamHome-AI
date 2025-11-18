import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// AI 分析進度屏幕 - 顯示分析過程和進度
class AnalysisScreen extends ConsumerStatefulWidget {
  final String? photoPath;
  final String? roomType;

  const AnalysisScreen({
    super.key,
    this.photoPath,
    this.roomType,
  });

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  final List<String> _steps = [
    '正在上傳照片...',
    'AI 正在分析房間...',
    '識別物品和問題...',
    '正在生成建議...',
    '準備完成...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 模擬步驟進度
    _simulateProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _currentStep = 3);
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _currentStep = 4);
      }
    });

    // 在完成後跳轉到建議屏幕
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/suggestion');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 正在分析'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // 隱藏返回按鈕
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 主動畫
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 旋轉加載動畫
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 背景圓形
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                      ),

                      // 旋轉邊框
                      RotationTransition(
                        turns: _animationController,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 4,
                              ),
                              bottom: BorderSide(
                                color: Colors.transparent,
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 中央圖標
                      Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      )
                          .animate(onPlay: (controller) {
                        controller.repeat(reverse: true);
                      })
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                            duration: const Duration(milliseconds: 600),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 進度百分比
                Text(
                  '${((_currentStep + 1) / _steps.length * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // 當前進度步驟描述
                Text(
                  _steps[_currentStep],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 進度指示器
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 步驟進度條
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _steps.length,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),

                // 步驟詳情
                Column(
                  children: List.generate(_steps.length, (index) {
                    final isCompleted = index < _currentStep;
                    final isCurrent = index == _currentStep;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // 步驟圓圈
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted || isCurrent
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 步驟描述
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: TextStyle(
                                fontSize: 13,
                                color: isCurrent
                                    ? Theme.of(context).primaryColor
                                    : isCompleted
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                fontWeight:
                                    isCurrent ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 取消按鈕
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: OutlinedButton(
              onPressed: _cancelAnalysis,
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelAnalysis() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('取消分析'),
          content: const Text('您確定要取消正在進行的分析嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('繼續'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 關閉對話框
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('取消分析'),
            ),
          ],
        );
      },
    );
  }
}

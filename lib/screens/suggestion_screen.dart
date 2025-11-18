import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 建議屏幕 - 顯示 AI 分析結果和收納建議
class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  // 模擬數據
  final double _cleanlinessScore = 6.5;
  final List<String> _mainIssues = ['衣服堆積在地板上', '書籍隨意放置', '缺乏收納空間'];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'priority': 1,
      'title': '整理衣服堆積',
      'description': '購買衣服收納盒來組織衣物',
      'time': '30分鐘',
      'difficulty': '簡單',
      'difficultyLevel': 1,
    },
    {
      'priority': 2,
      'title': '書籍分類收納',
      'description': '使用書架或收納柜整理書籍',
      'time': '1.5小時',
      'difficulty': '中等',
      'difficultyLevel': 2,
    },
    {
      'priority': 3,
      'title': '增加儲物空間',
      'description': '考慮安裝牆壁架或使用床下儲物盒',
      'time': '3小時',
      'difficulty': '難',
      'difficultyLevel': 3,
    },
  ];

  final bool _isSubscribed = false; // 訂閱狀態

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收納建議'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 整體評分卡
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '整齊度評分',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            _cleanlinessScore.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '/ 10.0',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 150,
                        height: 100,
                        child: CustomPaint(
                          painter: ScoreGaugePainter(
                            score: _cleanlinessScore,
                            maxScore: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '改善潛力: 預估可提升至 8.5/10',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 主要問題卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '發現的主要問題',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._mainIssues.map((issue) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orange[50],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(issue)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 建議列表
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分步建議方案',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._suggestions.map((suggestion) {
                    return _buildSuggestionCard(context, suggestion);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 操作按鈕
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  // 對話功能（訂閱用戶）
                  if (_isSubscribed)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/conversation');
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('向 AI 詢問更多'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('請升級到 Premium 以解鎖 AI 對話功能'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('AI 對話（需訂閱）'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // 分享和保存
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareSuggestion,
                          icon: const Icon(Icons.share),
                          label: const Text('分享'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saveSuggestion,
                          icon: const Icon(Icons.bookmark_outline),
                          label: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 反饋按鈕
                  OutlinedButton.icon(
                    onPressed: _provideFeedback,
                    icon: const Icon(Icons.feedback_outlined),
                    label: const Text('提供反饋'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    Map<String, dynamic> suggestion,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 標題和優先級
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '優先級 ${suggestion['priority']}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion['title'],
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),

          // 內容
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion['description'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            suggestion['time'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildDifficultyBadge(
                        suggestion['difficulty'],
                        suggestion['difficultyLevel'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 詳情按鈕
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed('/suggestion-detail', arguments: suggestion);
              },
              child: const Text('查看詳情'),
            ),
          ),
        ],
      ),
    );
  }

  /// 構建難度徽章，根據難度級別使用不同顏色
  Widget _buildDifficultyBadge(String difficulty, int difficultyLevel) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (difficultyLevel) {
      case 1: // 簡單
        bgColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        icon = Icons.trending_down;
        break;
      case 2: // 中等
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        icon = Icons.trending_flat;
        break;
      case 3: // 難
        bgColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        icon = Icons.trending_up;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _shareSuggestion() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('分享功能即將推出')));
  }

  void _saveSuggestion() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('建議已保存')));
  }

  void _provideFeedback() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提供反饋'),
          content: const Text('這些建議對您有幫助嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('不有幫助'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('感謝您的反饋！')));
              },
              child: const Text('有幫助'),
            ),
          ],
        );
      },
    );
  }
}

/// 自定義評分儀表盤繪製器
class ScoreGaugePainter extends CustomPainter {
  final double score;
  final double maxScore;

  ScoreGaugePainter({required this.score, required this.maxScore});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 畫圓
    canvas.drawCircle(center, radius, paint);

    // 畫進度弧
    final sweepAngle = (score / maxScore) * (3.14159 * 2);
    paint.strokeWidth = 4;
    paint.color = Colors.white;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

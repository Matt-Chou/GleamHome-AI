/// 歡迎/引導屏幕
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/app_constants.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late final AuthService? authService;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 開發階段：暫時不初始化 AuthService，避免 API 連接錯誤
    authService = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // 按左方向鍵回到上一頁
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // 按右方向鍵前往下一頁
            if (_currentPage < 3) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return KeyEventResult.handled;
          }
          
          return KeyEventResult.ignored;
        },
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  // 檢測水平滑動手勢
                  if (details.delta.dx > 5) {
                    // 向右滑動，回到上一頁
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (details.delta.dx < -5) {
                    // 向左滑動，前往下一頁
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  // 提高滑鼠滾輪和拖拽的敏感度
                  physics: const BouncingScrollPhysics(),
                children: [
                  _buildIntroPage(
                    title: '歡迎來到 ${AppConstants.appName}',
                    subtitle: '智能居家收納與清潔助手',
                    icon: Icons.home,
                  ),
                  _buildIntroPage(
                    title: '只需拍照',
                    subtitle: '簡單拍攝/上傳照片',
                    icon: Icons.camera_alt,
                  ),
                  _buildIntroPage(
                    title: 'AI 分析',
                    subtitle: '智能識別和分析',
                    icon: Icons.auto_awesome,
                  ),
                  _buildIntroPage(
                    title: '獲得建議',
                    subtitle: '獲得具體的收納、清潔方案',
                    icon: Icons.lightbulb,
                  ),
                ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_currentPage == 3)
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          // 確保先登出任何現有會話
                          await FirebaseAuth.instance.signOut();
                          
                          // 使用 Firebase Auth 進行 Google 登入
                          final auth = FirebaseAuth.instance;
                          final googleProvider = GoogleAuthProvider();
                          
                          // 設定 GoogleAuthProvider 參數，強制顯示帳號選擇
                          googleProvider.setCustomParameters({
                            'prompt': 'select_account', // 強制顯示帳號選擇頁面
                          });
                          
                          final userCredential = await auth.signInWithPopup(googleProvider);
                          final user = userCredential.user;
                          
                          if (user != null) {
                            // 顯示登入成功訊息
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('歡迎，${user.displayName ?? user.email}！')),
                            );
                            
                            // 開發階段：直接跳轉到主頁，不調用後端API
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Google 登入已取消')),
                            );
                          }
                        } catch (e) {
                          debugPrint('Google 登入錯誤: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Google 登入錯誤: ${e.toString()}')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('使用 Google 帳號登入'),
                    )
                  else
                    Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: const Text('上一步'),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('下一步'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildIntroPage({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

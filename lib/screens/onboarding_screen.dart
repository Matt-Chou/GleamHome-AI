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
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
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
        child: Stack(
          children: [
            // 背景圖片與滑動手勢
            GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx > 5) {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (details.delta.dx < -5) {
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
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildBackgroundImage('assets/images/onboarding/login1.png'),
                  _buildBackgroundImage('assets/images/onboarding/login2.png'),
                  _buildBackgroundImage('assets/images/onboarding/login3.png'),
                  _buildBackgroundImage('assets/images/onboarding/login4.png'),
                ],
              ),
            ),
            // 內容
            Align(
              alignment: Alignment.center,
              child: _buildContentForPage(_currentPage),
            ),
            // 按鈕區域
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_currentPage == 3)
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              final auth = FirebaseAuth.instance;
                              final googleProvider = GoogleAuthProvider();
                              googleProvider.setCustomParameters({
                                'prompt': 'select_account',
                              });
                              final userCredential = await auth.signInWithPopup(googleProvider);
                              final user = userCredential.user;
                              if (user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('歡迎，${user.displayName ?? user.email}！')),
                                );
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
                            backgroundColor: Colors.white.withOpacity(0.28),
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.white.withOpacity(0.85), width: 1.4),
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
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
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
                                  backgroundColor: Colors.white.withOpacity(0.8),
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('下一步'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContentForPage(int pageIndex) {
    final pages = [
      {
        'title': '歡迎來到 ${AppConstants.appName}',
        'subtitle': '智能居家收納與清潔助手',
        'icon': Icons.home,
      },
      {
        'title': '只需拍照',
        'subtitle': '簡單拍攝/上傳照片',
        'icon': Icons.camera_alt,
      },
      {
        'title': 'AI 分析',
        'subtitle': '智能識別和分析',
        'icon': Icons.auto_awesome,
      },
      {
        'title': '獲得建議',
        'subtitle': '獲得具體的收納、清潔方案',
        'icon': Icons.lightbulb,
      },
    ];

    final page = pages[pageIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade700.withOpacity(0.2), // 深灰色背景
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade600.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              page['icon'] as IconData, 
              size: 64, 
              color: Colors.white, // 白色圖標
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.transparent, // 透明背景
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  page['title'] as String,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9), // #000000, 90% opacity
                        offset: Offset(0.5, 0.5),
                        blurRadius: 0.8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  page['subtitle'] as String,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.99),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9), // #000000, 90% opacity
                        offset: Offset(0.5, 0.5),
                        blurRadius: 0.8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

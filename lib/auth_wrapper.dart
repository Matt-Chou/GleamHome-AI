import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

/// 認證包裝器 - 根據登入狀態決定顯示哪個頁面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 連接狀態檢查
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 檢查是否有登入用戶
        if (snapshot.hasData && snapshot.data != null) {
          // 用戶已登入，顯示主頁面
          return const HomeScreen();
        } else {
          // 用戶未登入，顯示登入頁面
          return const OnboardingScreen();
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/photo_review_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/suggestion_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/photo-review': (context) => const PhotoReviewScreen(),
        '/analysis': (context) => const AnalysisScreen(),
        '/suggestion': (context) => const SuggestionScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

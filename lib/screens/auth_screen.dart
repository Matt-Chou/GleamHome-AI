/// 認證屏幕 - 社交登入
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('登入'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              '使用社交帳號登入',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '選擇你偏好的登入方式',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 錯誤訊息
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    authState.error ?? '發生錯誤',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),

            // Google 登入
            FilledButton.icon(
              onPressed: authState.loading
                  ? null
                  : () async {
                      await authNotifier.socialLogin('google', 'fake-google-token');
                      final newUser = ref.read(authNotifierProvider).user;
                      if (newUser != null && context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
              icon: const Icon(Icons.login),
              label: const Text('使用 Google 登入'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),

            // Facebook 登入
            FilledButton.icon(
              onPressed: authState.loading
                  ? null
                  : () async {
                      await authNotifier.socialLogin('facebook', 'fake-facebook-token');
                      final newUser = ref.read(authNotifierProvider).user;
                      if (newUser != null && context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
              icon: const Icon(Icons.facebook),
              label: const Text('使用 Facebook 登入'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),

            // Apple 登入
            FilledButton.icon(
              onPressed: authState.loading
                  ? null
                  : () async {
                      await authNotifier.socialLogin('apple', 'fake-apple-token');
                      final newUser = ref.read(authNotifierProvider).user;
                      if (newUser != null && context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
              icon: const Icon(Icons.apple),
              label: const Text('使用 Apple 登入'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 24),

            // 加載指示器
            if (authState.loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

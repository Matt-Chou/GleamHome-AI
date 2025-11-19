/// 主頁面
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showUserProfileBottomSheet() {
    final user = FirebaseAuth.instance.currentUser;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 用戶頭像和信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null 
                        ? const Icon(Icons.person, size: 30) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? '未知用戶',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          user?.email ?? '未登入',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 登出按鈕
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context).pop(); // 關閉底部面板
                        Navigator.of(context).pushReplacementNamed('/onboarding'); // 返回登入頁面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已成功登出')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('登出失敗: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('登出 Google 帳號'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GleamHome AI'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text('主頁面', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('項目架構已建立完成', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    // 導航到拍照頁面
                    Navigator.of(context).pushNamed('/camera');
                  },
                  child: const Text('開始拍照'),
                ),
                const SizedBox(width: 24),
                OutlinedButton(
                  onPressed: () {
                    // 導航到拍照頁面並自動觸發相簿選擇
                    Navigator.of(
                      context,
                    ).pushNamed('/camera', arguments: {'pickGallery': true});
                  },
                  child: const Text('上傳圖片'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // 點擊個人頁面時顯示個人信息底部面板
            _showUserProfileBottomSheet();
            // 不更新選中狀態，保持在當前頁面
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '歷史'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '個人'),
        ],
      ),
    );
  }
}

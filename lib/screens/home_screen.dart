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

  void _showMenuDrawer() {
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
              const Divider(height: 32),
              
              // 登出按鈕
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/onboarding');
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

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '案例分享',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCaseCard(
            '智慧居家照明',
            '透過 AI 辨識環境光線，自動調整室內燈光',
            Icons.lightbulb_outline,
            Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildCaseCard(
            '家電能源管理',
            '即時監控家電用電狀況，提供節能建議',
            Icons.energy_savings_leaf,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildCaseCard(
            '空調智能控制',
            '根據室溫和人員活動自動調節空調',
            Icons.ac_unit,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildCaseCard(
            '安全監控系統',
            'AI 影像辨識，即時偵測異常狀況',
            Icons.security,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
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

  Widget _buildAnalysisPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            '開始分析您的居家環境',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '拍攝或上傳家電照片，AI 將為您分析能源使用狀況並提供優化建議',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/camera');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('開始拍照'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/camera', arguments: {'pickGallery': true});
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('上傳圖片'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPage() {
    // 這裡之後會從資料庫讀取歷史記錄
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暫無歷史記錄',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '開始使用後，您的分析記錄會顯示在這裡',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildAnalysisPage(),
      _buildHistoryPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GleamHome AI'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showMenuDrawer,
            tooltip: '選單',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '分析'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '歷史'),
        ],
      ),
    );
  }
}

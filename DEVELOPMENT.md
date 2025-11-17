# GleamHome AI - 開發指南

## 快速開始

### 1. 環境準備
```bash
# 克隆項目
git clone <repository-url>
cd gleamhome

# 安裝 Flutter 依賴
flutter pub get

# 複製環境變數文件
cp .env.example .env

# 編輯 .env 配置本地 API 服務器
API_BASE_URL=http://localhost:5000
```

### 2. 運行應用
```bash
# 開發模式
flutter run

# Release 模式
flutter run --release

# 指定設備
flutter run -d <device-id>
```

### 3. 後端服務啟動
本地開發需要啟動後端服務：

```bash
cd backend

# 創建虛擬環境
python -m venv venv
source venv/bin/activate  # 或 venv\Scripts\activate (Windows)

# 安裝依賴
pip install -r requirements.txt

# 初始化數據庫
python -m flask db upgrade

# 啟動服務
flask run --port 5000
```

## 項目架構說明

### 層級結構
```
config/     → 應用配置（常量、API、主題）
models/     → 數據模型
services/   → 業務邏輯（API、認證、額度等）
screens/    → 頁面層
widgets/    → 可復用 UI 組件
providers/  → Riverpod 狀態管理
utils/      → 工具函數
```

### 數據流向
```
Screens 
  ↓
Providers (Riverpod)
  ↓
Services (API、Auth、Quota 等)
  ↓
Models (數據模型)
  ↓
API 端點
```

## 開發規範

### 1. 命名約定
- 文件名：`snake_case` (如 `photo_analysis.dart`)
- 類名：`PascalCase` (如 `PhotoAnalysis`)
- 常量：`camelCase` (如 `defaultImageQuality`)
- 私有變數：`_camelCase` (如 `_currentUser`)

### 2. 代碼組織
- 導入語句按順序排列：dart、flutter、packages
- 使用 const constructor 優化性能
- 避免深層嵌套的 Widget

### 3. 錯誤處理
```dart
try {
  final result = await apiService.get('/api/endpoint');
  return result;
} catch (e) {
  throw Exception('操作失敗: $e');
}
```

### 4. 狀態管理（Riverpod）
所有需要共享的狀態應該使用 Riverpod Provider：

```dart
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref.watch(authServiceProvider));
});
```

## 常見開發任務

### 添加新的 API 端點
1. 在 `ApiConfig` 中添加端點路徑
2. 在相應的 Service 中實現方法
3. 在 Provider 中暴露該功能
4. 在 Screen 中調用

示例：
```dart
// 1. 在 ApiConfig 中
static const String newEndpoint = '/new-endpoint';

// 2. 在 Service 中
Future<NewData> fetchNewData() async {
  return await apiService.get('/api/new-endpoint');
}

// 3. 在 Provider 中
final newDataProvider = FutureProvider<NewData>((ref) {
  return ref.watch(serviceProvider).fetchNewData();
});

// 4. 在 Screen 中使用
final newData = ref.watch(newDataProvider);
```

### 添加新的頁面
1. 在 `screens/` 目錄中創建新文件
2. 實現 `StatelessWidget` 或 `StatefulWidget`
3. 在 `main.dart` 的路由配置中添加
4. 從其他頁面導航到新頁面

### 添加新的 UI 組件
1. 在 `widgets/` 目錄中創建新文件
2. 提取複雜的 UI 邏輯到組件
3. 使用 const constructor 優化性能
4. 添加完整的文檔註釋

## 測試

### 運行所有測試
```bash
flutter test

# 或帶詳細輸出
flutter test --verbose
```

### 添加新的測試
在 `test/` 目錄下創建測試文件：

```dart
void main() {
  group('PhotoAnalysis', () {
    test('應該正確解析 JSON', () {
      final json = {'analysis_id': '123', ...};
      final analysis = PhotoAnalysis.fromJson(json);
      
      expect(analysis.analysisId, '123');
    });
  });
}
```

## 調試

### 啟用詳細日誌
```bash
flutter run -v
```

### 使用 DevTools
```bash
# 啟動 DevTools
flutter pub global activate devtools
devtools

# 或通過 Flutter
flutter pub global run devtools
```

### 檢查性能
使用 DevTools 的 Performance 面板檢查：
- 幀率（FPS）
- CPU 使用
- 內存使用

## 常見問題

### Q: 應用無法連接到後端
A: 檢查 .env 中的 API_BASE_URL 是否正確，後端服務是否正在運行

### Q: 依賴版本衝突
A: 運行 `flutter pub get` 或 `flutter pub upgrade`

### Q: Hot Reload 不生效
A: 使用 Hot Restart (`r`) 或重新運行應用

### Q: 圖片選擇器無法使用
A: 檢查 AndroidManifest.xml 和 Info.plist 中的權限設置

## 部署檢查清單

在上線前檢查以下事項：

- [ ] 所有 API 端點都已實現
- [ ] 所有錯誤都有適當的處理
- [ ] 性能測試通過（< 3s 啟動時間）
- [ ] 安全測試通過（JWT、加密）
- [ ] 所有單元測試通過
- [ ] 應用圖標和啟動屏幕已設置
- [ ] 隱私政策和服務條款已編寫
- [ ] 發佈配置已設置（簽名密鑰等）

## 資源

- [Flutter 官方文檔](https://flutter.dev/docs)
- [Riverpod 文檔](https://riverpod.dev)
- [Dio 文檔](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io)

## 聯繫和支持

如有任何問題或需要幫助，請：
1. 查看 ARCHITECTURE.md 中的相關部分
2. 檢查是否有相似的實現
3. 提交 Issue 或 Pull Request

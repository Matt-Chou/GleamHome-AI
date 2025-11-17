# GleamHome AI - 項目架構文檔

## 項目概述
根據 Proposal.md 的計畫，GleamHome AI 是一款 AI 驅動的智能居家收納助手。本文檔描述已建立的項目架構。

## 目錄結構

```
lib/
├── main.dart                          # 應用入口
├── config/
│   ├── app_constants.dart            # 應用常量配置
│   ├── api_config.dart               # API 和 AI 服務配置
│   └── app_theme.dart                # 應用主題和樣式
├── models/
│   ├── user.dart                     # 用戶模型
│   ├── user_quota.dart               # 用戶額度模型
│   ├── photo_analysis.dart           # 照片分析結果模型
│   ├── organization_suggestion.dart  # 收納建議模型
│   └── ai_conversation.dart          # AI 對話歷史模型
├── services/
│   ├── api_service.dart              # API 服務基類
│   ├── auth_service.dart             # 認證服務
│   ├── quota_service.dart            # 額度管理服務
│   └── ai_service.dart               # AI 分析服務
├── screens/
│   ├── onboarding_screen.dart        # 歡迎/引導屏幕
│   └── home_screen.dart              # 主頁面
├── widgets/                           # (待實現) UI 組件
├── providers/                         # (待實現) Riverpod 狀態管理
└── utils/                             # (待實現) 工具類
```

## 已實現的核心功能

### 1. 配置層 (config/)
- **AppConstants**: 應用級別的常量配置
  - API 基礎 URL
  - 額度配置（免費版、付費版）
  - Token 配置
  - 訂閱價格
  
- **ApiConfig**: API 端點和 AI 服務配置
  - 認證、額度、分析、對話等 API 端點
  - OpenAI 模型配置
  - 圖片壓縮參數

- **AppTheme**: 統一的應用主題
  - 顏色方案（主色、次色、強調色等）
  - 文本樣式（使用 Google Fonts - Poppins）
  - 按鈕、輸入框等 UI 元件樣式

### 2. 數據模型層 (models/)
- **User**: 用戶信息（ID、郵箱、名稱、訂閱等級）
- **UserQuota**: 用戶額度（日分析次數、Token 額度）
- **PhotoAnalysis**: 照片分析結果（評分、識別物體、問題等）
- **OrganizationSuggestion**: 收納建議（優先級、步驟、推薦產品）
- **AIConversation**: AI 對話記錄（消息、Token 使用等）

### 3. 服務層 (services/)
- **ApiService**: 基礎 API 通信
  - HTTP 客戶端（使用 Dio）
  - 請求攔截器（JWT token 管理）
  - 錯誤處理

- **AuthService**: 認證管理
  - 社交登入（Google、Facebook、Apple）
  - 會話恢復
  - 登出功能

- **QuotaService**: 額度管理
  - 獲取額度狀態
  - 檢查是否可以分析
  - 消耗額度

- **AIService**: AI 分析服務
  - 照片分析
  - 建議生成
  - AI 對話

### 4. 屏幕層 (screens/)
- **OnboardingScreen**: 歡迎引導（4 頁 PageView）
- **HomeScreen**: 主頁面（底部導航）

## 依賴包

已在 pubspec.yaml 中添加的主要依賴：

### 認證
- firebase_core, firebase_auth
- google_sign_in, flutter_facebook_auth, sign_in_with_apple

### 狀態管理
- riverpod, flutter_riverpod

### 本地存儲
- hive, hive_flutter, shared_preferences

### 相機和圖片
- camera, image_picker, image, flutter_image_compress

### 網絡請求
- dio, retrofit

### UI
- google_fonts, flutter_animate, shimmer, chat_bubbles

### 工具
- intl, path_provider, uuid, logger, flutter_dotenv

## 下一步開發計畫

### Phase 1: 狀態管理 (Riverpod Providers)
- [ ] AuthProvider - 認證狀態
- [ ] QuotaProvider - 額度狀態
- [ ] PhotoProvider - 照片管理
- [ ] AnalysisProvider - 分析結果管理
- [ ] ConversationProvider - 對話管理

### Phase 2: 頁面開發
按優先級：
1. **認證屏幕** (AuthScreen) - 社交登入按鈕
2. **相機屏幕** (CameraScreen) - 拍照功能
3. **分析屏幕** (AnalysisScreen) - 加載動畫
4. **建議屏幕** (SuggestionScreen) - 建議展示
5. **對話屏幕** (ConversationScreen) - AI 對話
6. **歷史屏幕** (HistoryScreen) - 分析歷史
7. **設置屏幕** (SettingsScreen) - 用戶設置

### Phase 3: UI 組件開發
- [ ] QuotaBadge - 額度顯示
- [ ] SuggestionCard - 建議卡片
- [ ] LoadingAnimation - 加載動畫
- [ ] ChatMessage - 對話氣泡
- [ ] BeforeAfterSlider - 前後對比滑塊

### Phase 4: 功能集成
- [ ] 圖片壓縮和上傳
- [ ] Token 計算邏輯
- [ ] 離線模式支持
- [ ] 本地數據持久化（Hive）

### Phase 5: 測試和優化
- [ ] 單元測試（models, services）
- [ ] Widget 測試（screens, widgets）
- [ ] 性能優化
- [ ] 安全測試（Token、數據加密）

## 環境設置

1. **創建 .env 文件**（複製 .env.example）
   ```bash
   cp .env.example .env
   ```

2. **配置環境變數**
   - API_BASE_URL: 後端 API 地址
   - Firebase 配置（如果使用）
   - 社交登入 API Keys

3. **安裝依賴**
   ```bash
   flutter pub get
   ```

4. **運行應用**
   ```bash
   flutter run
   ```

## API 端點參考

根據 Proposal.md 中的設計：

### 認證
- POST `/api/auth/social-login` - 社交登入
- POST `/api/auth/logout` - 登出
- GET `/api/user/profile` - 獲取用戶信息

### 額度管理
- GET `/api/quota/status` - 獲取額度狀態
- POST `/api/quota/check` - 檢查是否可分析
- POST `/api/quota/consume` - 消耗額度

### AI 分析
- POST `/api/analyze` - 照片分析
- POST `/api/suggestions` - 生成建議
- POST `/api/conversation` - AI 對話
- GET `/api/conversation/{analysis_id}/history` - 對話歷史

## 技術決策

1. **狀態管理**: Riverpod
   - 原因：響應式、類型安全、易於測試

2. **HTTP 客戶端**: Dio
   - 原因：功能完整、易於使用、有攔截器支持

3. **本地存儲**: Hive + SharedPreferences
   - 原因：Hive 適合複雜數據，SharedPreferences 適合簡單設置

4. **認證**: Firebase Auth + 社交登入 SDK
   - 原因：安全、功能完整、易於集成

5. **主題**：Material Design 3
   - 原因：現代化、統一的設計語言

## 注意事項

1. **JWT Token 管理**
   - Token 存儲在 SecureStorage 中
   - 自動在 API 請求中附加
   - 過期時自動清除

2. **額度控制**
   - 在實際分析前檢查額度
   - 分析後自動消耗額度
   - 每日午夜重置

3. **圖片處理**
   - 自動壓縮至 2048x2048
   - 質量設置為 85（0-100）
   - 支持 JPG、PNG、WebP

4. **離線支持**
   - 歷史記錄可離線查看
   - 無網絡時顯示提示
   - 重新連接時自動同步

## 文件修改日期
- 創建日期: 2025-11-17
- 最後更新: 2025-11-17

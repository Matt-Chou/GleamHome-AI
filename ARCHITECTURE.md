# GleamHome AI - 項目架構文檔

## 項目概述
根據 Proposal.md 的計畫，GleamHome AI 是一款 AI 驅動的智能居家收納助手。本文檔描述已建立的項目架構，包括最新的 Firebase 集成和 Google 登入功能。

## 目錄結構

```
├── Firebase 配置層
│   ├── firebase_options_secure.dart     # 安全的 Firebase 配置（使用環境變數）
│   ├── .env                             # 環境變數文件（敏感信息）
│   ├── .env.example                     # 環境變數模板
│   ├── android/app/google-services.json # Android Firebase 配置
│   └── web/index.html                   # Web Firebase SDK 集成
│
lib/
├── main.dart                          # 應用入口（已集成 Firebase 初始化）
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
│   ├── onboarding_screen.dart        # ✅ 歡迎/引導屏幕（已實現 Google 登入）
│   ├── home_screen.dart              # ✅ 主頁面
│   ├── auth_screen.dart              # ✅ 認證頁面
│   ├── camera_screen.dart            # ✅ 相機拍照頁面
│   ├── photo_review_screen.dart      # ✅ 照片預覽頁面
│   ├── analysis_screen.dart          # ✅ AI 分析頁面
│   └── suggestion_screen.dart        # ✅ 建議顯示頁面
├── widgets/                           # (待實現) UI 組件
├── providers/                         # (待實現) Riverpod 狀態管理
└── utils/                             # (待實現) 工具類
```

## 已實現的核心功能

### 0. Firebase 集成層 🔥 **NEW**
- **firebase_options_secure.dart**: 安全的 Firebase 配置管理
  - 使用環境變數保護 API 密鑰
  - 多平台配置（Android/iOS/Web/Windows）
  - 動態配置載入
  
- **.env 環境變數管理**: 敏感信息隔離
  - Firebase API 密鑰
  - Google OAuth 客戶端 ID
  - 各平台專用配置
  - Git 安全（已排除敏感文件）

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

- **AuthService**: 認證管理 ✅ **已部分實現**
  - ✅ Google 登入（Firebase Auth + signInWithPopup）
  - ⏳ Facebook 登入（待實現）
  - ⏳ Apple 登入（待實現）
  - ✅ JWT Token 管理
  - ✅ 會話恢復邏輯
  - ✅ 登出功能

- **QuotaService**: 額度管理
  - 獲取額度狀態
  - 檢查是否可以分析
  - 消耗額度

- **AIService**: AI 分析服務
  - 照片分析
  - 建議生成
  - AI 對話

### 4. 屏幕層 (screens/) ✅ **已實現 7 個頁面**
- **OnboardingScreen**: 歡迎引導頁面 ✅ **已完成**
  - 4 頁 PageView 引導流程
  - Google 登入按鈕集成
  - 多種導航支持（滑鼠拖拽、鍵盤方向鍵、觸控滑動、按鈕點擊）
  - 響應式按鈕布局
  - 錯誤處理和用戶反饋
  
- **HomeScreen**: 主頁面框架 ✅ **已完成**
  - 底部導航結構
  - 基礎頁面佈局
  
- **其他頁面**: 基礎結構已創建 ✅
  - AuthScreen, CameraScreen, PhotoReviewScreen
  - AnalysisScreen, SuggestionScreen

## 依賴包

已在 pubspec.yaml 中添加的主要依賴：

### 認證 ✅ **已配置**
- firebase_core: ^4.2.1 ✅
- firebase_auth: ^6.1.2 ✅  
- firebase_analytics: ^12.0.4 ✅
- google_sign_in: ^7.2.0 ✅
- flutter_dotenv: ^6.0.0 ✅ **環境變數管理**

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

### Phase 1: 拍照上傳模塊 📸 **優先級最高**
- [ ] **相機功能完善** (CameraScreen)
  - 實時拍照功能
  - 照片預覽和編輯
  - 圖片壓縮優化
- [ ] **照片管理** (PhotoReviewScreen)
  - 從相冊選擇照片
  - 照片裁切和旋轉
  - 上傳進度顯示

### Phase 2: 後端 API 集成 🚀
- [ ] **Python Flask 後端開發**
  - OpenAI Vision API 集成
  - GPT-4 文本生成
  - 用戶認證 API
  - 額度管理系統
- [ ] **前後端連接**
  - HTTP 客戶端完善
  - API 錯誤處理
  - 離線模式支持

### Phase 3: 狀態管理 (Riverpod Providers)
- [ ] AuthProvider - 認證狀態（基於 Firebase Auth）
- [ ] QuotaProvider - 額度狀態
- [ ] PhotoProvider - 照片管理
- [ ] AnalysisProvider - 分析結果管理
- [ ] ConversationProvider - 對話管理

### Phase 4: UI/UX 完善
- [ ] **分析流程優化** (AnalysisScreen)
- [ ] **建議展示改進** (SuggestionScreen)
- [ ] **AI 對話功能** (ConversationScreen)
- [ ] **歷史記錄** (HistoryScreen)
- [ ] **用戶設置** (SettingsScreen)

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

## 環境設置 ✅ **已完成**

1. **創建 .env 文件** ✅
   ```bash
   # Windows PowerShell
   Copy-Item .env.example .env
   ```

2. **配置環境變數** ✅ **已完成**
   - Firebase API 密鑰（Web/Android/iOS/Windows）
   - Google OAuth 客戶端 ID
   - Firebase 項目配置
   - 授權域名和 Bundle ID

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

1. **認證服務**: Firebase Auth ✅ **已實現**
   - 原因：安全、功能完整、多平台支持
   - 實現：Google 登入已完成，支持 Web/Android/iOS
   - 優勢：無需自建認證系統，自動處理 Token 管理

2. **配置管理**: 環境變數 + flutter_dotenv ✅ **已實現**
   - 原因：安全隔離敏感信息，支持多環境部署
   - 實現：.env 文件管理 API 密鑰，Git 自動排除
   - 優勢：開發/生產環境配置分離

3. **狀態管理**: Riverpod ⏳ **待實現**
   - 原因：響應式、類型安全、易於測試

4. **HTTP 客戶端**: Dio ⏳ **待實現**
   - 原因：功能完整、易於使用、有攔截器支持

5. **本地存儲**: Hive + SharedPreferences ⏳ **待實現**
   - 原因：Hive 適合複雜數據，SharedPreferences 適合簡單設置

6. **主題**：Material Design 3 ✅ **已實現**
   - 原因：現代化、統一的設計語言
   - 實現：自定義主題配置，Google Fonts 集成

## 注意事項

1. **Firebase 安全配置** 🔒 **重要**
   - API 密鑰存儲在 .env 文件中，已排除於 Git
   - 各平台使用獨立的 Firebase 應用配置
   - Web 平台已配置授權域名限制
   - google-services.json 已排除於版本控制

2. **JWT Token 管理**
   - Firebase 自動處理 Token 生成和刷新
   - Token 存儲在 Firebase SDK 內部安全存儲
   - 過期時自動重新認證

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

## 實現統計 📊

### 完成功能
- ✅ **Firebase 多平台集成**: Android, iOS, Web, Windows
- ✅ **Google 登入功能**: 一鍵社交認證
- ✅ **安全配置管理**: 環境變數隔離敏感信息
- ✅ **多導航支持**: 滑鼠、鍵盤、觸控、按鈕四種方式
- ✅ **響應式 UI**: 適配桌面和移動端
- ✅ **基礎頁面架構**: 7 個頁面基礎結構

### 技術債務
- ⏳ 後端 API 尚未實現
- ⏳ Riverpod 狀態管理待集成
- ⏳ 相機功能待完善
- ⏳ AI 分析服務待連接

## 文件修改日期
- 創建日期: 2025-11-17
- 最後更新: 2025-11-19
- Firebase 集成: 2025-11-19
- Google 登入實現: 2025-11-19

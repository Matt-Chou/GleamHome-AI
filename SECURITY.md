# 🔒 Firebase 安全配置指南

## 📋 已完成的安全設定

### ✅ 環境變數保護
- 建立了 `.env` 檔案存放敏感資訊
- 更新了 `.gitignore` 防止敏感檔案被提交
- 建立了 `env.example` 作為範例檔案

### ✅ 程式碼更新
- `lib/firebase_options_secure.dart` - 使用環境變數的安全配置
- `lib/main.dart` - 載入環境變數
- `web/index.html` - 移除硬編碼配置

## 🚀 如何在其他環境部署

### 1. 開發環境
```bash
# 複製範例檔案
cp env.example .env
# 編輯 .env 填入真實值
```

### 2. 生產環境
- 在伺服器設定環境變數
- 使用 CI/CD 系統的秘密管理
- 避免在程式碼中硬編碼任何敏感資訊

## 🔐 保護的敏感資訊
- Firebase API Keys
- Firebase App IDs
- Google OAuth Client IDs
- Firebase 專案相關配置

## ⚠️ 注意事項
- 永遠不要提交 `.env` 檔案到 Git
- 定期輪換 API Keys
- 在 Firebase Console 設定 API Key 限制
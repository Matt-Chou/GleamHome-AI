/// GleamHome AI - 應用常量配置
class AppConstants {
  // API 配置
  static const String apiBaseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api/v1';

  // 用戶額度配置
  static const int freeTierDailyAnalysis = 1;
  static const int premiumTierDailyAnalysis = 5;
  static const int premiumTierMonthlyAnalysis = 150;

  // Token 配置
  static const int premiumTierDailyTokens = 1000;
  static const int averageTokensPerAnalysis = 500;
  static const int averageTokensPerConversation = 100;

  // 應用信息
  static const String appName = 'GleamHome AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = '智能居家收納助手 - 拍照獲取 AI 收納建議';

  // 訂閱價格
  static const double subscriptionPrice = 1200.0; // TWD
  static const String subscriptionCurrency = 'TWD';

  // 存儲鍵
  static const String storageKeyUser = 'user_info';
  static const String storageKeyJwt = 'jwt_token';
  static const String storageKeyQuota = 'user_quota';
  static const String storageKeyPreferences = 'user_preferences';
}

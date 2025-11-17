/// API 配置文件
class ApiConfig {
  // 認證端點
  static const String socialLogin = '/auth/social-login';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user/profile';

  // 額度管理端點
  static const String quotaStatus = '/quota/status';
  static const String quotaCheck = '/quota/check';
  static const String quotaConsume = '/quota/consume';

  // AI 分析端點
  static const String analyze = '/analyze';
  static const String generateSuggestions = '/suggestions';
  static const String conversation = '/conversation';
  static const String conversationHistory = '/conversation/{analysis_id}/history';

  // 歷史記錄端點
  static const String analysisHistory = '/history/analyses';
  static const String deleteAnalysis = '/history/analyses/{analysis_id}';
}

/// AI 服務提供商配置
class AIServiceConfig {
  // OpenAI 配置
  static const String openaiVisionModel = 'gpt-4-vision-preview';
  static const String openaiTextModel = 'gpt-4-turbo';
  static const int visionTokensPerImage = 500;

  // 支持的語言
  static const List<String> supportedLanguages = ['zh_TW', 'en_US', 'ja_JP'];

  // 圖片壓縮配置
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const int imageQuality = 85; // 0-100
}

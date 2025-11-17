/// 用戶額度模型
class UserQuota {
  final String userId;
  final int dailyAnalysisLimit;
  final int dailyAnalysisUsed;
  final int dailyTokenLimit;
  final int dailyTokenUsed;
  final DateTime quotaResetTime;
  final String subscriptionTier;

  UserQuota({
    required this.userId,
    required this.dailyAnalysisLimit,
    required this.dailyAnalysisUsed,
    required this.dailyTokenLimit,
    required this.dailyTokenUsed,
    required this.quotaResetTime,
    required this.subscriptionTier,
  });

  int get dailyAnalysisRemaining => dailyAnalysisLimit - dailyAnalysisUsed;
  int get dailyTokenRemaining => dailyTokenLimit - dailyTokenUsed;

  factory UserQuota.fromJson(Map<String, dynamic> json) {
    return UserQuota(
      userId: json['user_id'],
      dailyAnalysisLimit: json['daily_analysis_limit'],
      dailyAnalysisUsed: json['daily_analysis_used'],
      dailyTokenLimit: json['daily_token_limit'],
      dailyTokenUsed: json['daily_token_used'],
      quotaResetTime: DateTime.parse(json['quota_reset_time']),
      subscriptionTier: json['subscription_tier'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'daily_analysis_limit': dailyAnalysisLimit,
    'daily_analysis_used': dailyAnalysisUsed,
    'daily_token_limit': dailyTokenLimit,
    'daily_token_used': dailyTokenUsed,
    'quota_reset_time': quotaResetTime.toIso8601String(),
    'subscription_tier': subscriptionTier,
  };
}

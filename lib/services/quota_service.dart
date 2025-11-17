/// 額度管理服務
import '../models/user_quota.dart';
import 'api_service.dart';

class QuotaService {
  final ApiService apiService;

  UserQuota? _currentQuota;

  QuotaService(this.apiService);

  UserQuota? get currentQuota => _currentQuota;

  Future<UserQuota> getQuotaStatus() async {
    try {
      final response = await apiService.get('/api/quota/status');
      _currentQuota = UserQuota.fromJson(response);
      return _currentQuota!;
    } catch (e) {
      throw Exception('獲取額度狀態失敗: $e');
    }
  }

  Future<bool> canAnalyze(int tokensNeeded) async {
    try {
      final quota = await getQuotaStatus();
      return quota.dailyAnalysisRemaining > 0 &&
          quota.dailyTokenRemaining > tokensNeeded;
    } catch (e) {
      return false;
    }
  }

  Future<void> consumeQuota({
    required String operation,
    required int tokensConsumed,
  }) async {
    try {
      await apiService.post(
        '/api/quota/consume',
        data: {
          'operation': operation, // 'analyze', 'conversation'
          'tokens_consumed': tokensConsumed,
        },
      );
      
      // 刷新額度狀態
      await getQuotaStatus();
    } catch (e) {
      throw Exception('消耗額度失敗: $e');
    }
  }

  int get dailyAnalysisRemaining => _currentQuota?.dailyAnalysisRemaining ?? 0;
  int get dailyTokenRemaining => _currentQuota?.dailyTokenRemaining ?? 0;
}

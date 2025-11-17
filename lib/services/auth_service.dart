/// 認證服務
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  User? _currentUser;

  AuthService(this.apiService);

  User? get currentUser => _currentUser;

  Future<User> socialLogin(String provider, String token) async {
    try {
      final response = await apiService.post(
        '/api/auth/social-login',
        data: {
          'provider': provider, // 'google', 'facebook', 'apple'
          'token': token,
        },
      );

      final user = User.fromJson(response);
      _currentUser = user;

      // 保存 JWT token
      final jwtToken = response['jwt_token'];
      await secureStorage.write(
        key: AppConstants.storageKeyJwt,
        value: jwtToken,
      );
      apiService.setJwtToken(jwtToken);

      return user;
    } catch (e) {
      throw Exception('社交登入失敗: $e');
    }
  }

  Future<void> logout() async {
    try {
      await apiService.post('/api/auth/logout');
      _currentUser = null;
      await secureStorage.delete(key: AppConstants.storageKeyJwt);
      apiService.clearJwtToken();
    } catch (e) {
      throw Exception('登出失敗: $e');
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await apiService.get('/api/user/profile');
      final user = User.fromJson(response);
      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('獲取用戶信息失敗: $e');
    }
  }

  Future<bool> restoreSession() async {
    try {
      final jwtToken = await secureStorage.read(
        key: AppConstants.storageKeyJwt,
      );

      if (jwtToken != null) {
        apiService.setJwtToken(jwtToken);
        _currentUser = await getUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool get isAuthenticated => _currentUser != null;
}

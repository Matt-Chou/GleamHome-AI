/// API 服務基類
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/app_constants.dart';

class ApiService {
  late Dio _dio;
  String? _jwtToken;

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? AppConstants.apiBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 添加攔截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_jwtToken != null) {
            options.headers['Authorization'] = 'Bearer $_jwtToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token 過期，需要重新登入
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setJwtToken(String token) {
    _jwtToken = token;
  }

  void clearJwtToken() {
    _jwtToken = null;
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('連接超時，請檢查網絡');
      case DioExceptionType.receiveTimeout:
        return Exception('接收超時，請檢查網絡');
      case DioExceptionType.badResponse:
        return Exception('服務器錯誤: ${e.response?.statusCode}');
      default:
        return Exception('網絡錯誤: ${e.message}');
    }
  }
}

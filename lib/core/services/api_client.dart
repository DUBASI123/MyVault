import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../storage/app_storage.dart';

/// Authenticated HTTP client for the My Vault Node.js API.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get instance {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio!.interceptors.removeWhere((i) => i is _AuthInterceptor);
    _dio!.interceptors.add(_AuthInterceptor());
    return _dio!;
  }

  static Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    final res = await instance.get(path, queryParameters: query);
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getMap(String path, {Map<String, dynamic>? query}) async {
    final res = await instance.get(path, queryParameters: query);
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    final res = await instance.post(path, data: data);
    return res.data as Map<String, dynamic>;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AppStorage.instance.getToken();
    if (token != null && !token.startsWith('mock_jwt_')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

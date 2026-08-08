// lib/features/auth/data/services/dio_client.dart
//
// Builds the Dio instance used to talk to the NestJS backend on Render.
// Reads a developer-set backend URL override from secure storage first
// (set via the Developer Settings screen), falling back to the default
// production URL — so a device with a stale backend URL can be pointed
// at a new one without rebuilding the app.
//
// Add to pubspec.yaml: dio: ^5.4.0

import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

/// Update this if your Render deployment URL changes.
const String kDefaultBackendUrl = 'https://myvault-f08x.onrender.com';

class DioClient {
  DioClient({required SecureStorageService storage}) : _storage = storage {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final base = await _storage.readBackendUrlOverride() ?? kDefaultBackendUrl;
        options.baseUrl = base;
        final token = await _storage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  Dio get dio => _dio;
}

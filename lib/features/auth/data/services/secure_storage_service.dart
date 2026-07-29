// lib/features/auth/data/services/secure_storage_service.dart
//
// Wraps flutter_secure_storage for the two pieces of durable local state
// auth needs: the JWT and an optional developer-set backend URL override
// (see Developer Settings, opened by long-pressing the login logo).
//
// Add to pubspec.yaml: flutter_secure_storage: ^9.0.0

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'myvault_jwt_token';
  static const _backendUrlKey = 'myvault_backend_url_override';

  // --- Auth token ---

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // --- Developer-set backend URL override ---

  Future<void> saveBackendUrlOverride(String url) =>
      _storage.write(key: _backendUrlKey, value: url);

  Future<String?> readBackendUrlOverride() => _storage.read(key: _backendUrlKey);

  Future<void> clearBackendUrlOverride() => _storage.delete(key: _backendUrlKey);
}

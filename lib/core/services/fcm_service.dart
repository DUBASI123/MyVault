import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles mock FCM lifecycle for pure offline/mock client mode.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Mock initialization.
  Future<void> init(GoRouter router) async {
    debugPrint('[FCM] Mock FCM Service initialized (Firebase disabled)');
  }

  /// Mock clear token.
  Future<void> clearTokenOnLogout() async {
    // No-op
  }
}

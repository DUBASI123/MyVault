import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {
    debugPrint('NotificationService: initialized (stub, Firebase disabled)');
  }
}

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background handler MUST be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[FCM][background] ${message.messageId}: ${message.data}');
  }
}

/// Handles FCM token lifecycle, local notification display while the app
/// is foregrounded, and deep-link routing when a notification is tapped.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'myvault_default',
    'MyVault Notifications',
    description: 'Academic updates, jobs, internships, and announcements',
    importance: Importance.high,
  );

  /// Call once from main(), after Supabase + Firebase are initialized.
  Future<void> init(GoRouter router) async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _requestPermission();
      await _initLocalNotifications();

      FirebaseMessaging.onMessage.listen((message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _routeFromMessage(message, router);
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _routeFromMessage(initialMessage, router);
      }

      await _registerToken();
      _messaging.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF6C63FF),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['deep_link'] as String?,
    );
  }

  void _routeFromMessage(RemoteMessage message, GoRouter router) {
    final deepLink = message.data['deep_link'];
    if (deepLink is String && deepLink.isNotEmpty) {
      router.push(deepLink);
    }
  }

  Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    if (studentId == null) return;

    await Supabase.instance.client.from('device_tokens').upsert(
      {
        'student_id': studentId,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'student_id,fcm_token',
    );
  }

  Future<void> clearTokenOnLogout() async {
    final token = await _messaging.getToken();
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    if (token == null || studentId == null) return;
    await Supabase.instance.client
        .from('device_tokens')
        .delete()
        .eq('student_id', studentId)
        .eq('fcm_token', token);
  }
}

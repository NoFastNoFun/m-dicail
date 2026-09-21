import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Android-only FCM bootstrap: token, campaigns topic, tap routing, API register.
@lazySingleton
class PushNotificationService {
  PushNotificationService(this._apiClient, this._tokenStorage);

  static const _campaignsTopic = 'campaigns';
  static const _medicalWatchType = 'medical_watch';

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  String? _currentToken;
  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  String? get currentToken => _currentToken;

  /// Call once from [main] on Android after [Firebase.initializeApp].
  Future<void> initialize() async {
    if (!_isAndroid || _initialized) return;
    _initialized = true;

    // Keep In-App Messaging SDK loaded (Console campaigns / FIAM).
    await FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);

    await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission();

    try {
      await FirebaseMessaging.instance.subscribeToTopic(_campaignsTopic);
    } catch (e) {
      debugPrint('FCM subscribeToTopic failed: $e');
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _currentToken = token;
      debugPrint('FCM token: $token');
    }

    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _currentToken = token;
      unawaited(registerWithBackendIfAuthenticated());
    });

    _openedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageTap(initial);
      });
    }
  }

  /// Register the current FCM token with the API when a real JWT session exists.
  Future<void> registerWithBackendIfAuthenticated() async {
    if (!_isAndroid) return;
    final authToken = await _tokenStorage.readToken();
    if (authToken == null || authToken == AppConfig.mockAdminToken) return;

    final fcmToken =
        _currentToken ?? await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;
    _currentToken = fcmToken;

    try {
      await _apiClient.post<void>(
        '/devices',
        data: {'token': fcmToken, 'platform': 'android'},
      );
    } catch (e) {
      debugPrint('FCM device register failed: $e');
    }
  }

  /// Unregister the token from the API. Must run while the JWT is still valid.
  Future<void> unregisterFromBackend() async {
    if (!_isAndroid) return;
    final fcmToken = _currentToken;
    if (fcmToken == null) return;

    try {
      await _apiClient.delete<void>(
        '/devices',
        data: {'token': fcmToken},
      );
    } catch (e) {
      debugPrint('FCM device unregister failed: $e');
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final type = message.data['type'];
    // medical_watch and generic campaigns both open medical watch for now.
    if (type == null || type == _medicalWatchType) {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        GoRouter.of(context).go(AppRoutes.medicalWatch);
      }
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _openedAppSub?.cancel();
  }
}

/// Initialize Firebase + push on Android only. Safe no-op elsewhere.
Future<void> initializeFirebaseIfAndroid() async {
  if (!_isAndroid) return;
  await Firebase.initializeApp();
}

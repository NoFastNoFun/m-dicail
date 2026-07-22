import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/recording_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class RecordingNotificationService {
  Future<void> ensureInitialized();

  Future<void> requestPermissions();

  Future<void> start({
    required String title,
    required String body,
  });

  Future<void> update({
    required String title,
    required String body,
  });

  Future<void> stop();
}

@LazySingleton(as: RecordingNotificationService)
class RecordingNotificationServiceImpl implements RecordingNotificationService {
  static const _serviceId = 256;
  static const _channelId = 'medicail_recording';
  static const _channelName = 'Enregistrement consultation';
  static const _channelDescription =
      'Notification affichee pendant une ecoute en cours.';

  bool _initialized = false;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: _channelDescription,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        await Permission.microphone.request();
      }
    }
  }

  @override
  Future<void> start({
    required String title,
    required String body,
  }) async {
    await ensureInitialized();
    await requestPermissions();

    if (await FlutterForegroundTask.isRunningService) {
      await update(title: title, body: body);
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: const [ForegroundServiceTypes.microphone],
      notificationTitle: title,
      notificationText: body,
      callback: recordingForegroundTaskCallback,
    );
  }

  @override
  Future<void> update({
    required String title,
    required String body,
  }) async {
    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: body,
    );
  }

  @override
  Future<void> stop() async {
    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.stopService();
  }
}

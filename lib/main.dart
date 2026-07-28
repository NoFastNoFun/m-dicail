import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:medicail/app/medicail_app.dart';
import 'package:medicail/core/config/app_platform.dart';
import 'package:medicail/core/debug/desktop_debug_backend_url_store.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/layout/app_system_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await AppSystemUi.configure();
  await configureDependencies();
  if (isDesktopDebugBackendUrlEnabled) {
    await getIt<DesktopDebugBackendUrlStore>().hydrate();
  }
  runApp(const MedicailApp());
}

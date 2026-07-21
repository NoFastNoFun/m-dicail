import 'package:flutter/material.dart';
import 'package:medicail/app/medicail_app.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/layout/app_system_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSystemUi.configure();
  await configureDependencies();
  runApp(const MedicailApp());
}

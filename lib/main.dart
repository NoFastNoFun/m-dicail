import 'package:flutter/material.dart';
import 'package:medicail/app/medicail_app.dart';
import 'package:medicail/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MedicailApp());
}

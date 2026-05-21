import 'package:flutter/material.dart';
import 'package:medicail/app/medicail_app.dart';
import 'package:medicail/core/di/injection.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await configureDependencies();
  runApp(const MedicailApp());
}

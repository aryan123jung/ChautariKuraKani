import 'package:chautari_kurakani/app/app.dart';
import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  final container = ProviderContainer();
  await container.read(hiveServiceProvider).init();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

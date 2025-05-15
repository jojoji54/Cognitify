import 'package:cognitify/app.dart';
import 'package:cognitify/models/dataset_info.dart';
import 'package:cognitify/models/duration_adapter.dart';
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Registra los adaptadores antes de abrir las cajas
  Hive.registerAdapter(DatasetInfoAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(TestResultAdapter());
  Hive.registerAdapter(DurationAdapter());

  // Abre las cajas necesarias con tipos específicos
  await Hive.openBox<UserProfile>('userBox');
  await Hive.openBox<TestResult>('resultsBox');
  await Hive.openBox<DatasetInfo>('datasets');

  runApp(CognitifyApp());
}

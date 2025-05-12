import 'package:cognitify/app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Abre las cajas necesarias
  await Hive.openBox('userBox');
  await Hive.openBox('resultsBox');
  runApp( CognitifyApp());
}


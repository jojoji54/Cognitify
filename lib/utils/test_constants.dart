import 'package:cognitify/models/test_result.dart';
import 'package:hive/hive.dart';

class Constant{

static Future<void> saveTestResult(String testName, double score, Duration duration, Map<String, dynamic> data, int difficulty) async {
  final resultsBox = await Hive.openBox<TestResult>('resultsBox');

  // Añadir dificultad al rawData
  data["difficulty"] = difficulty;

  // Busca si ya existe un TestResult para este tipo de juego
  final existingIndex = resultsBox.values.toList().indexWhere((r) => r.testName == testName);

  if (existingIndex != -1) {
    // Añade el nuevo resultado al objeto existente
    final existingTestResult = resultsBox.getAt(existingIndex)!;
    existingTestResult.addResult(score, duration, data, difficulty);
    print("✅ Resultado añadido a '${existingTestResult.testName}'");
  } else {
    // Crea un nuevo objeto si no existe
    final newTestResult = TestResult(
      testName: testName,
      date: DateTime.now(),
      scores: [score],
      durations: [duration],
      rawData: [data],
    );
    await resultsBox.add(newTestResult);
    print("✅ Nuevo TestResult creado para '$testName'");
  }
}




}
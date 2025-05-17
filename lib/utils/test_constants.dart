import 'package:cognitify/models/test_result.dart';
import 'package:hive/hive.dart';

class Constant {
  static Future<void> saveTestResult(String testName, double score,
      Duration duration, Map<String, dynamic> data, int difficulty) async {
    final resultsBox = await Hive.openBox<TestResult>('resultsBox');

    // Añadir dificultad al rawData
    data["difficulty"] = difficulty;

    // Busca si ya existe un TestResult para este tipo de juego
    final existingIndex =
        resultsBox.values.toList().indexWhere((r) => r.testName == testName);

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

  static String generatePrompt(double averageScore, averageResponseTime,
      accuracy, userPercentile, String dataSetName, dataSetUrl) {
    return """
Eres un experto en análisis de rendimiento cognitivo, especializado en pruebas de memoria. Evalúa los siguientes resultados del usuario, considerando los diferentes aspectos del rendimiento en tareas de memoria:

- Puntuación promedio: $averageScore
- Tiempo de respuesta promedio: $averageResponseTime segundos
- Precisión: $accuracy%
- Percentil del usuario: $userPercentile%

Además, ten en cuenta que este análisis se basa en un dataset específico (de nombre $dataSetName y url $dataSetUrl) que mide habilidades de memoria en diferentes niveles de dificultad.

Proporciona un análisis detallado del rendimiento del usuario, incluyendo:
1. Puntos fuertes.
2. Posibles áreas de mejora.
3. Consejos para mejorar la memoria y el rendimiento en este tipo de tareas.

Responde de manera clara y estructurada y no te dejes nada quiero los 3 puntos y no uses mas de 500 caracteres.
""";
  }

  static String prompt="";
}

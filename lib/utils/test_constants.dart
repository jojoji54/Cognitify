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

  static String generatePromptSecuenceMemory(
      double averageScore,
      averageResponseTime,
      accuracy,
      userPercentile,
      String dataSetName,
      dataSetUrl) {
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

Responde con claridad, sin exceder los 500 caracteres y estructurando bien los 3 puntos, importante que si ves que el usuario pueda tener algun problema cognitivo, no dudes en comentarlo y en darle las pautas que adecuadas
""";
  }

  static String generatePromptPairMemory(
    double averageScore,
    double averageResponseTime,
    double accuracy,
    double userPercentile,
    int totalErrors,
    double totalUserScore,
    int maxConsecutivePairs,
    int bestTime,
    int totalGamesPlayed,
    String dataSetName,
    String dataSetUrl,
  ) {
    return """
Eres un experto en análisis cognitivo. Evalúa el rendimiento del usuario en un test de memoria basado en emparejar cartas, considerando estos valores:

- Puntuación promedio: $averageScore
- Tiempo de respuesta promedio: ${averageResponseTime.toStringAsFixed(2)} s
- Precisión: ${accuracy.toStringAsFixed(2)}%
- Percentil: ${userPercentile.toStringAsFixed(2)}%
- Total de errores: $totalErrors
- Puntuación total acumulada: ${totalUserScore.toStringAsFixed(2)}
- Racha máxima sin errores: $maxConsecutivePairs
- Mejor tiempo en partida: ${bestTime}s
- Total de partidas jugadas: $totalGamesPlayed

Además, ten en cuenta que este análisis se basa en un dataset específico (de nombre $dataSetName y url $dataSetUrl) que mide habilidades de memoria en diferentes niveles de dificultad.

Analiza:
1. Puntos fuertes.
2. Debilidades o áreas a mejorar.
3. Recomendaciones prácticas para fortalecer la memoria visual.

Responde con claridad, sin exceder los 500 caracteres y estructurando bien los 3 puntos, importante que si ves que el usuario pueda tener algun problema cognitivo, no dudes en comentarlo y en darle las pautas que adecuadas.
""";
  }

  static String prompt = "";
}

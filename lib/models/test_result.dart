import 'package:hive/hive.dart';

part 'test_result.g.dart';

@HiveType(typeId: 0)
class TestResult extends HiveObject {
  @HiveField(0)
  String testName;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<double> scores;

  @HiveField(3)
  List<Duration> durations;

  @HiveField(4)
  List<Map<String, dynamic>> rawData;

  TestResult({
    required this.testName,
    required this.date,
    required this.scores,
    required this.durations,
    required this.rawData,
  });

  // Añadir un nuevo resultado con dificultad
  void addResult(double score, Duration duration, Map<String, dynamic> data, int difficulty) {
    scores.add(score);
    durations.add(duration);
    rawData.add({
      ...data,
      "difficulty": difficulty,  // Incluye el nivel de dificultad
    });
    save();
  }

  // Calcular la media de los últimos N resultados
  double averageScore({int lastN = 20}) {
    int count = scores.length < lastN ? scores.length : lastN;
    return scores.take(count).reduce((a, b) => a + b) / count;
  }

  // Obtener el tiempo promedio de los últimos N resultados
  Duration averageDuration({int lastN = 20}) {
    int count = durations.length < lastN ? durations.length : lastN;
    int totalMilliseconds = durations
        .take(count)
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    return Duration(milliseconds: (totalMilliseconds / count).round());
  }

  // Calcular la media por nivel de dificultad
  double averageScoreByDifficulty(int difficulty, {int lastN = 20}) {
    final filteredScores = rawData
        .where((data) => data["difficulty"] == difficulty)
        .take(lastN)
        .map((data) => data["score"] as double)
        .toList();

    if (filteredScores.isEmpty) return 0.0;
    return filteredScores.reduce((a, b) => a + b) / filteredScores.length;
  }

  // Calcular el total de juegos jugados
  int totalGamesPlayed() {
    return scores.length;
  }

  // Calcular el promedio de errores para un nivel de dificultad
  double averageErrorsByDifficulty(int difficulty, {int lastN = 20}) {
    final filteredErrors = rawData
        .where((data) => data["difficulty"] == difficulty)
        .take(lastN)
        .map((data) => data["errors"] as int)
        .toList();

    if (filteredErrors.isEmpty) return 0.0;
    return filteredErrors.reduce((a, b) => a + b) / filteredErrors.length;
  }

  // Calcular el puntaje máximo alcanzado para un nivel de dificultad
  double maxScoreByDifficulty(int difficulty) {
    final filteredScores = rawData
        .where((data) => data["difficulty"] == difficulty)
        .map((data) => data["score"] as double)
        .toList();

    if (filteredScores.isEmpty) return 0.0;
    return filteredScores.reduce((a, b) => a > b ? a : b);
  }

  // Añadir estadísticas globales
  static Future<void> saveGlobalStats(double score, int difficulty, int errors, Duration duration) async {
    try {
      final resultsBox = await Hive.openBox<TestResult>('resultsBox');

      // Busca si ya existe un TestResult global
      final existingIndex = resultsBox.values.toList().indexWhere((r) => r.testName == "Global Stats");

      final rawData = {
        "difficulty": difficulty,
        "score": score,
        "errors": errors,
        "duration": duration.inMilliseconds,
        "date": DateTime.now().toString(),
      };

      if (existingIndex != -1) {
        // Añade el nuevo resultado al objeto existente
        final existingTestResult = resultsBox.getAt(existingIndex)!;
        existingTestResult.addResult(score, duration, rawData, difficulty);
        print("✅ Estadísticas globales actualizadas.");
      } else {
        // Crea un nuevo objeto si no existe
        final newTestResult = TestResult(
          testName: "Global Stats",
          date: DateTime.now(),
          scores: [score],
          durations: [duration],
          rawData: [rawData],
        );
        await resultsBox.add(newTestResult);
        print("✅ Nuevo TestResult creado para estadísticas globales.");
      }
    } catch (e) {
      print("❌ Error al guardar las estadísticas globales: $e");
    }
  }
}

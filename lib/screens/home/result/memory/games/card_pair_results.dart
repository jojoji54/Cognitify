import 'package:cognitify/models/user_profile.dart';
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/models/dataset_info.dart';
import 'package:cognitify/screens/home/result/memory/games/widget/neumorphic_analysis_tile.dart';
import 'package:cognitify/utils/test_constants.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class CardPairsResults extends StatefulWidget {
  const CardPairsResults({Key? key}) : super(key: key);

  @override
  State<CardPairsResults> createState() => _CardPairsResultsState();
}

class _CardPairsResultsState extends State<CardPairsResults> {
  List<TestResult> results = [];
  List<double> datasetScores = [];
  bool isLoading = true;
  double _averageScore = 0.0;
  double _averageResponseTime = 0.0;
  double _accuracy = 0.0;
  double _userPercentile = 0.0;
  int _totalErrors = 0;
  bool isLoadingAnalysis = false;
  String analysisResult = "";
  String dataSetName = "";
  String dataSetUrl = "";

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final resultsBox = await Hive.openBox<TestResult>('resultsBox');
    final datasetBox = await Hive.openBox<DatasetInfo>('datasets');
    final userBox = await Hive.openBox<UserProfile>('userBox');

    // Cargar resultados del usuario
    results = resultsBox.values
        .where((r) => r.testName == "Parejas de Cartas")
        .toList();

    // Cargar perfil del usuario
    final userProfile = userBox.get('profile');
    int userAge = userProfile?.age ?? 30;
    String userId = userProfile?.name ?? "R1001P";

    // Cargar datos del dataset por tipo (Memoria - Parejas de Cartas)
    final dataset = datasetBox.values.firstWhere(
      (d) =>
          d.type == "Memoria" &&
          d.subtype == "Pareja de cartas" &&
          d.jsonData != null &&
          d.jsonData!.isNotEmpty,
      orElse: () => DatasetInfo(
        name: "Sin datos",
        url: "",
        type: "Memoria",
        subtype: "Pareja de cartas",
        dateAdded: DateTime.now(),
        jsonData: [],
      ),
    );
    dataSetName = dataset.name;
    dataSetUrl = dataset.url;

    // Filtrar datos del dataset para el usuario actual
    datasetScores = dataset.jsonData!
        .where((entry) => entry["answer"] != null)
        .map((entry) => double.tryParse(entry["answer"].toString()) ?? 0.0)
        .toList();

    // Calcula las estadísticas del usuario
    final userScores = results.expand((r) => r.scores).toList();

    // Puntuación promedio del usuario
    _averageScore = userScores.isNotEmpty
        ? userScores.reduce((a, b) => a + b) / userScores.length
        : 0.0;

    // Tiempo de respuesta promedio del usuario
    final totalDurations =
        results.expand((r) => r.durations).map((d) => d.inSeconds).toList();
    _averageResponseTime = totalDurations.isNotEmpty
        ? totalDurations.reduce((a, b) => a + b) / totalDurations.length
        : 0.0;

    // Precisión total del usuario
    final totalCorrect = userScores.where((s) => s > 0).length;
// Total de intentos (incluyendo correctos e incorrectos)
    final totalAttempts = results
        .expand((r) => r.rawData)
        .where((data) => data["trial_type"] == "PAIR")
        .length;

// Total de errores
    _totalErrors = results
        .expand((r) => r.rawData)
        .where((data) => data["answer"] == -1) // Solo cuenta los errores
        .length;

// Calcula la precisión correctamente
    _accuracy = totalAttempts > 0
        ? ((totalAttempts - _totalErrors) / totalAttempts) * 100
        : 0.0;

    // Calcular percentil
    int totalPoints = 0;
    int maxPossiblePoints = 0;

    for (var result in results) {
      for (int i = 0; i < result.scores.length; i++) {
        double score = result.scores[i];
        int difficulty = result.rawData[i]["difficulty"] ?? 1;
        double adjustedScore = score * (1 + (difficulty - 1) * 0.1);
        totalPoints += adjustedScore.round();
        maxPossiblePoints += 500;
      }
    }

    // Ajusta el percentil para que esté entre 0 y 100
    _userPercentile =
        maxPossiblePoints > 0 ? (totalPoints / maxPossiblePoints) * 100 : 0.0;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const Center(
        child: Text(
          "No hay resultados para 'Parejas de Cartas'.",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 80, 80, 80),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildBarChart(),
              const SizedBox(height: 20),
              _buildResultsTable(),
              const SizedBox(height: 20),
              NeumorphicAnalysisTile(
                isLoading: isLoadingAnalysis,
                analysisResult: analysisResult,
                onAnalyze: () {
                  setState(() {
                    analysisResult = "🧠 Análisis en progreso...";
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Calcula el percentil del usuario
  double calculateUserPercentile(
      List<double> userScores, List<double> datasetScores) {
    if (userScores.isEmpty || datasetScores.isEmpty) return 0.0;

    // Junta todos los puntajes (usuario y dataset)
    final allScores = [...datasetScores, ...userScores]..sort();

    // Encuentra la posición del puntaje promedio del usuario en el conjunto total
    final userAverage = userScores.reduce((a, b) => a + b) / userScores.length;
    final position = allScores.indexWhere((score) => score >= userAverage);

    // Calcula el percentil
    return (position / allScores.length) * 100;
  }

  Widget _buildSummaryCard() {
    final datasetAverage = datasetScores.isNotEmpty
        ? datasetScores.reduce((a, b) => a + b) / datasetScores.length
        : 0.0;

    // Calcula la puntuación total del usuario
    final totalUserScore =
        results.expand((r) => r.scores).fold(0.0, (sum, score) => sum + score);

    // Calcula el máximo de parejas consecutivas sin error
    int maxConsecutivePairs = 0;
    int currentStreak = 0;
    for (var result in results) {
      for (var data in result.rawData) {
        final errors = int.tryParse(data["errors"].toString()) ?? 0;
        if (errors == 0) {
          currentStreak++;
          if (currentStreak > maxConsecutivePairs) {
            maxConsecutivePairs = currentStreak;
          }
        } else {
          currentStreak = 0;
        }
      }
    }

    // Encuentra el mejor tiempo para completar una partida
    final bestTime = results
        .expand((r) => r.durations)
        .fold<Duration>(const Duration(hours: 999), (best, current) {
      return current < best ? current : best;
    });

    // Calcula el número total de partidas jugadas
    final totalGamesPlayed = results.length;
    // Cargar todos los resultados del usuario desde Hive
    final userScores = results.expand((r) => r.scores).toList();

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Resumen General",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "* Puntuación Promedio (Usuario): ${_averageScore.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "* Puntuación Promedio (Dataset): ${datasetAverage.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 120, 120, 120),
            ),
          ),
          Text(
            "* Tiempo de Respuesta Promedio: ${_averageResponseTime.toStringAsFixed(2)}s",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "* Precisión Total: ${_accuracy.toStringAsFixed(2)}%",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "* Total de Errores: $_totalErrors",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          const SizedBox(height: 5),
          Divider(
            thickness: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 5),
          Text(
            "* Puntuación Total (Usuario): ${totalUserScore.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
          Text(
            "* Máxima Racha sin Error: $maxConsecutivePairs",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
          Text(
            "* Mejor Tiempo: ${bestTime.inSeconds}s",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
          Text(
            "* Total de Partidas Jugadas: $totalGamesPlayed",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
          Text(
            "* Percentil del Usuario: ${calculateUserPercentile(userScores, datasetScores).toStringAsFixed(2)}%",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    // Aquí podemos ajustar los gráficos para representar pares correctamente
    return const Text("Gráfico aquí");
  }

  Widget _buildResultsTable() {
    // Aquí se mostrarán los resultados detallados
    return const Text("Tabla de resultados aquí");
  }
}

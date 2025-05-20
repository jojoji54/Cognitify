import 'package:cognitify/models/user_profile.dart';
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/models/dataset_info.dart';
import 'package:cognitify/screens/home/result/memory/games/widget/neumorphic_analysis_tile.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart' as radar;
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
  DatasetInfo? dataset;

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
    dataset = datasetBox.values.firstWhere(
      (d) => d.subtype == "Parejas de Cartas",
      orElse: () => DatasetInfo(
        name: "Sin datos",
        url: "",
        type: "Memoria",
        subtype: "Pareja de cartas",
        dateAdded: DateTime.now(),
        jsonData: [],
      ),
    );
    dataSetName = dataset!.name;
    dataSetUrl = dataset!.url;

    // Filtrar datos del dataset para el usuario actual
    datasetScores = dataset!.jsonData!
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
              _buildRadarChart(),
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
    // Filtra solo los valores que son respuestas válidas
    final datasetAnswers = dataset!.jsonData!
        .map((entry) => int.tryParse(entry["answer"].toString()) ?? -999)
        .where((answer) => answer != -999)
        .toList();

    print("📊 Respuestas del Dataset (filtradas): $datasetAnswers");

// Calcula el promedio si hay datos válidos
    final datasetAverage = datasetAnswers.isNotEmpty
        ? datasetAnswers.reduce((a, b) => a + b) / datasetAnswers.length
        : 0.0;

    print("📊 Promedio del Dataset (filtrado): $datasetAverage");

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

  Widget _buildRadarChart() {
    final ticks = [20, 40, 60, 80, 100]; // Enteros en porcentaje

    const features = ["Score", "Precision", "Errors", "Time", "Percentile"];

    final userData = [
      (_averageScore / 500).clamp(0.0, 1.0),
      (_accuracy / 100).clamp(0.0, 1.0),
      (1 -
              (_totalErrors /
                  (results
                      .expand((r) => r.rawData)
                      .length))) // menos errores mejor
          .clamp(0.0, 1.0),
      (1 - (_averageResponseTime / 60)).clamp(0.0, 1.0), // 60s como peor caso
      (_userPercentile / 100).clamp(0.0, 1.0),
    ];

    final datasetEntries = dataset!.jsonData!
        .where((e) => e["trial_type"] == "PROB" && e["answer"] != null)
        .toList();

    final datasetCorrect = datasetEntries.where((e) => e["answer"] == 1).length;
    final datasetTotal = datasetEntries.length;

    final datasetPrecision =
        datasetTotal > 0 ? (datasetCorrect / datasetTotal) * 100 : 0.0;
    final datasetErrors = datasetTotal - datasetCorrect;

    final datasetDurations = datasetEntries
        .map((e) => double.tryParse(e["duration"].toString()) ?? 0.0)
        .where((d) => d > 0)
        .toList();

    final datasetAvgDuration = datasetDurations.isNotEmpty
        ? datasetDurations.reduce((a, b) => a + b) / datasetDurations.length
        : 0.0;

    final datasetScore = datasetScores.isNotEmpty
        ? datasetScores.reduce((a, b) => a + b) / datasetScores.length
        : 0.0;

    final datasetData = [
      (datasetScore / 500).clamp(0.0, 1.0),
      (datasetPrecision / 100).clamp(0.0, 1.0),
      (1 - (datasetErrors / datasetTotal)).clamp(0.0, 1.0),
      (1 - (datasetAvgDuration / 60)).clamp(0.0, 1.0),
      0.75, // fijo o calculable si tienes percentil dataset
    ];

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "📊 Comparación Radar",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: radar.RadarChart.light(
              ticks: ticks,
              features: features,
              data: [
                userData.map((e) => (e * 100).round()).toList(),
                datasetData.map((e) => (e * 100).round()).toList(),
              ],
              reverseAxis: false,
              useSides: true,
            ),
          ),
          const SizedBox(height: 10),
          const Text("🔵 Tú vs 🟢 Dataset"),
          const SizedBox(height: 10),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("📊 Información del Gráfico"),
                    content: const Text(
                        "Este gráfico muestra una comparación entre tu rendimiento y el promedio del dataset en cinco aspectos clave:\n\n"
                        "🔹 *Score:* Tu puntuación promedio en los tests.\n"
                        "🔹 *Precisión:* Porcentaje de aciertos respecto al total de intentos.\n"
                        "🔹 *Errores:* Cuantos más errores, más pequeño será el área.\n"
                        "🔹 *Tiempo:* Tiempo medio que tardas en resolver los pares (menos es mejor).\n"
                        "🔹 *Percentil:* Qué tan por encima estás respecto al resto de personas del dataset.\n\n"
                        "🟦 Área Azul: Tus resultados\n"
                        "🟩 Área Verde: Promedio del dataset\n\n"
                        "👉 Cuanto más cerca del borde está un valor, mejor es el rendimiento en ese aspecto.\n"
                        "Esta visualización te permite detectar tus fortalezas y áreas donde puedes mejorar."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color.fromARGB(255, 80, 39, 176),
              size: 30,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final userScores = results.expand((r) => r.scores).toList();
    final attempts = results.expand((r) => r.rawData).length;
    final errors = _totalErrors;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "📊 Rendimiento",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: userScores.isNotEmpty
                            ? userScores.reduce((a, b) => a + b) /
                                userScores.length
                            : 0,
                        width: 20,
                        color: const Color.fromARGB(255, 80, 39, 176),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: attempts.toDouble(),
                        width: 20,
                        color: const Color.fromARGB(255, 150, 150, 150),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: errors.toDouble(),
                        width: 20,
                        color: const Color.fromARGB(255, 255, 100, 100),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text("Promedio");
                          case 1:
                            return const Text(" intentos");
                          case 2:
                            return const Text("Errores");
                          default:
                            return const Text("");
                        }
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 10),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("📊 Información del Gráfico"),
                    content: const Text(
                      "Este gráfico muestra un resumen de tu rendimiento en el juego 'Parejas de Cartas':\n\n"
                      "🟣 *Puntuación Promedio:* Muestra la media de tus puntuaciones en todas las partidas jugadas.\n"
                      "⚪ *Intentos Totales:* Representa el número total de parejas que intentaste resolver (aciertos e intentos fallidos).\n"
                      "🔴 *Total de Errores:* Indica cuántos intentos resultaron incorrectos.\n\n"
                      "Este gráfico te permite visualizar rápidamente tu desempeño general y detectar áreas de mejora.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color.fromARGB(255, 80, 39, 176),
              size: 30,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    // Aquí se mostrarán los resultados detallados
    return const Text("Tabla de resultados aquí");
  }
}

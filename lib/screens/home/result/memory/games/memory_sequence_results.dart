// lib/screens/results/games/memory_sequence_results.dart
import 'package:cognitify/models/user_profile.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/models/dataset_info.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MemorySequenceResults extends StatefulWidget {
  const MemorySequenceResults({Key? key}) : super(key: key);

  @override
  State<MemorySequenceResults> createState() => _MemorySequenceResultsState();
}

class _MemorySequenceResultsState extends State<MemorySequenceResults> {
  List<TestResult> results = [];
  List<double> datasetScores = [];
  bool isLoading = true;
  double _averageScore = 0.0;
  double _averageResponseTime = 0.0;
  double _accuracy = 0.0;
  double _userPercentile = 0.0;

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
        .where((r) => r.testName == "Secuencia de Números")
        .toList();

    // Cargar perfil del usuario
    final userProfile = userBox.get('profile');
    int userAge = userProfile?.age ?? 30;

    // Mapea el nivel de educación del perfil
    final educationLevelMapping = {
      "Primaria": "1.0",
      "Secundaria": "2.0",
      "Bachillerato": "3.0",
      "FP": "3.0",
      "Universitario": "4.0",
      "Postgrado": "5.0",
      "Otro": "6.0"
    };

    final genderMapping = {"Masculino": "m", "Femenino": "f", "Otro": null};

    final userEducationLevel =
        educationLevelMapping[userProfile?.educationLevel ?? "Otro"];
    final userGender = genderMapping[userProfile?.gender ?? "Otro"];

    // Cargar datos del dataset por tipo (Memoria)
    final dataset = datasetBox.values.firstWhere(
      (d) =>
          d.type == "Memoria" && d.jsonData != null && d.jsonData!.isNotEmpty,
      orElse: () => DatasetInfo(
        name: "Sin datos",
        url: "",
        type: "Memoria",
        dateAdded: DateTime.now(),
        jsonData: [],
      ),
    );

    // Filtrar usando el perfil del usuario
    datasetScores = dataset.jsonData!
        .where((entry) {
          final entryAge = double.tryParse(entry["age"]?.toString() ?? "");
          final entryEducation = entry["education_level"]?.toString();
          final entryGender = entry["gender"]?.toString();

          // Verifica la edad
          final ageMatch = entryAge == null || entryAge == userAge;

          // Verifica el nivel de educación
          final educationMatch = entryEducation == null ||
              entryEducation == "" ||
              entryEducation == userEducationLevel;

          // Verifica el género
          final genderMatch = entryGender == null ||
              entryGender == "" ||
              entryGender == userGender;

          return ageMatch && educationMatch && genderMatch;
        })
        .map((entry) => double.tryParse(entry["raw_score"].toString()) ?? 0.0)
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
    final totalAttempts = userScores.length;
    _accuracy = totalAttempts > 0 ? (totalCorrect / totalAttempts) * 100 : 0.0;

    // Calcular percentil basado en dificultad

    int totalPoints = 0;
    int totalDifficulties = 0;
    int maxPossiblePoints = 0;

    for (var result in results) {
      for (int i = 0; i < result.scores.length; i++) {
        double score = result.scores[i];
        int difficulty = result.rawData[i]["difficulty"] ?? 1;

        // Añade los puntos reales, ajustados por dificultad
        double adjustedScore = score * (1 + (difficulty - 1) * 0.1);
        totalPoints += adjustedScore.round();

        // Calcula el máximo posible para normalizar
        maxPossiblePoints += 100 * (1 + (difficulty - 1) * 0.1).round();
        totalDifficulties++;
      }
    }

// Ajusta el percentil para que esté entre 0 y 100
    _userPercentile =
        totalDifficulties > 0 ? (totalPoints / maxPossiblePoints) * 100 : 0.0;

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
          "No hay resultados para 'Secuencia de Números'.",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 80, 80, 80),
          ),
        ),
      );
    }

    if (datasetScores.isEmpty) {
      return const Center(
        child: Text(
          "No hay resultados para tu tipo de perfil",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(
              _averageScore,
              _averageResponseTime,
              _accuracy,
              _userPercentile,
            ),
            const SizedBox(height: 20),
            _buildLineChart(),
            const SizedBox(height: 20),
           // _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double averageScore, double averageResponseTime,
      double accuracy, double userPercentile) {
    final datasetAverage = datasetScores.isNotEmpty
        ? datasetScores.reduce((a, b) => a + b) / datasetScores.length
        : 0.0;

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
            "Puntuación Promedio (Usuario): ${averageScore.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "Puntuación Promedio (Dataset): ${datasetAverage.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 120, 120, 120),
            ),
          ),
          Text(
            "Tiempo de Respuesta Promedio: ${averageResponseTime.toStringAsFixed(2)}s",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "Precisión Total: ${accuracy.toStringAsFixed(2)}%",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "Percentil del Usuario: ${userPercentile.toStringAsFixed(2)}%",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
  return Neumorphic(
    style: NeumorphicStyle(
      depth: 6,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      color: NeumorphicTheme.baseColor(context),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              lineBarsData: [
                // Datos del Usuario (limitado a los últimos 50)
                LineChartBarData(
                  spots: results
                      .expand((r) => r.scores)
                      .skip((results.expand((r) => r.scores).length - 50)
                          .clamp(0, 50))
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => FlSpot(
                            entry.key.toDouble(),
                            entry.value,
                          ))
                      .toList(),
                  isCurved: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                  color: const Color.fromARGB(255, 80, 39, 176),
                ),
                // Datos del Dataset (limitado a los últimos 50 puntos)
                LineChartBarData(
                  spots: datasetScores
                      .skip((datasetScores.length - 50).clamp(0, 50))
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => FlSpot(
                            entry.key.toDouble(),
                            entry.value,
                          ))
                      .toList(),
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  color: const Color.fromARGB(255, 120, 120, 120),
                ),
              ],
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
                    "Este gráfico muestra la evolución de tu rendimiento en el test de 'Secuencia de Números'.\n\n"
                    "🔹 Línea morada: Tus últimos 50 resultados.\n"
                    "🔹 Línea gris: Resultados promedio del dataset para tu perfil.\n\n"
                    "Cada punto representa un intento individual, y las curvas están suavizadas para mostrar tendencias."
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
    if (results.isEmpty) {
      return Neumorphic(
        style: NeumorphicStyle(
          depth: 6,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          color: NeumorphicTheme.baseColor(context),
        ),
        padding: const EdgeInsets.all(20),
        child: const Text(
          "📋 No hay resultados registrados.",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 80, 80, 80),
          ),
        ),
      );
    }

    // Limita a los últimos 10 resultados
    final List<Map<String, dynamic>> allResults = [];

    for (var result in results.reversed.take(10)) {
      for (int i = 0; i < result.scores.length; i++) {
        allResults.add({
          "Fecha": result.date,
          "Dificultad": result.rawData[i]["difficulty"] ?? 1,
          "Puntuación": result.scores[i].toStringAsFixed(2),
          "Tiempo": result.durations[i].inSeconds.toString(),
          "Precisión": (result.scores[i] >= 100
              ? "100%"
              : "${result.scores[i].toStringAsFixed(2)}%"),
          "Errores": result.rawData[i]["errors"] ?? 0,
        });
      }
    }

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "📋 Resultados Detallados",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.symmetric(
              outside: const BorderSide(
                  color: Color.fromARGB(255, 80, 80, 80), width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
            },
            children: [
              // Encabezado
              const TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 200, 200, 200)),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Fecha",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Dificultad",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Puntuación",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Tiempo (s)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Precisión",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Errores",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Filas de datos
              ...allResults.map((result) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Fecha"].toString().split(" ").first),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Dificultad"].toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Puntuación"]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Tiempo"]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Precisión"]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(result["Errores"].toString()),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}

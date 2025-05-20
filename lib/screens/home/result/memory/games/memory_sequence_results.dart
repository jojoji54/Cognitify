// lib/screens/results/games/memory_sequence_results.dart
import 'package:cognitify/models/user_profile.dart';
import 'package:cognitify/screens/home/result/memory/games/widget/neumorphic_analysis_tile.dart';
import 'package:cognitify/services/ai/secuence_of_number_ai.dart';
import 'package:cognitify/utils/test_constants.dart';
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
        subtype: "",
        dateAdded: DateTime.now(),
        jsonData: [],
      ),
    );
    dataSetName = dataset.name;
    dataSetUrl = dataset.url;

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

  void _analyzeResults() async {
    setState(() {
      isLoadingAnalysis = true;
      analysisResult = "";
    });

    try {
      Constant.prompt = Constant.generatePromptSecuenceMemory(
          _averageScore,
          _averageResponseTime,
          _accuracy,
          _userPercentile,
          dataSetName,
          dataSetUrl);
      final String response =
          await SecuenceOfNumberAI.rewriteText(Constant.prompt);

      setState(() {
        analysisResult = response;
      });
    } catch (e) {
      setState(() {
        analysisResult =
            "Error al procesar el análisis. Inténtalo de nuevo más tarde.";
      });
    } finally {
      setState(() {
        isLoadingAnalysis = false;
      });
    }
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
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildSummaryCard(
                _averageScore,
                _averageResponseTime,
                _accuracy,
                _userPercentile,
              ),
              const SizedBox(height: 20),
              _buildLineChart(),
              const SizedBox(height: 20),
              _buildResultsTable(),
              const SizedBox(height: 20),
              NeumorphicAnalysisTile(
                isLoading: isLoadingAnalysis,
                analysisResult: analysisResult,
                onAnalyze: _analyzeResults,
              ),
              const SizedBox(height: 20),
            ],
          ),
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
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
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
                        "Cada punto representa un intento individual, y las curvas están suavizadas para mostrar tendencias."),
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
        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
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
        final score = result.scores[i];
        final precision =
            (score >= 100) ? "100%" : "${score.toStringAsFixed(2)}%";
        final errors = result.rawData[i]["errors"] ?? 0;
        final difficulty = result.rawData[i]["difficulty"] ?? 1;

        allResults.add({
          "Fecha": result.date,
          "Dificultad": difficulty,
          "Puntuación": score,
          "Tiempo": result.durations[i].inSeconds,
          "Precisión": precision,
          "Errores": errors,
          "isGood": score >= 100,
          "isBad": score == 0 ||
              errors > 3, // Considera "malo" si hay muchos errores
        });
      }
    }

    return Column(
      children: [
        Neumorphic(
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
                border: const TableBorder.symmetric(
                  outside: BorderSide(
                    color: Color.fromARGB(255, 80, 80, 80),
                    width: 1,
                  ),
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
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 200, 200, 200)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Fecha",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Dificultad",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Puntuación",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Tiempo (s)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Precisión",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text("Errores",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de datos
                  ...allResults.map((result) {
                    final isGood = result["isGood"];
                    final isBad = result["isBad"];
                    final rowColor = isGood
                        ? const Color.fromARGB(
                            255, 0, 150, 0) // Verde para buenos resultados
                        : isBad
                            ? const Color.fromARGB(
                                255, 200, 0, 0) // Rojo para malos resultados
                            : const Color.fromARGB(255, 80, 80,
                                80); // Gris para resultados neutrales

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Fecha"].toString().split(" ").first,
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Dificultad"].toString(),
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Puntuación"].toStringAsFixed(2),
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Tiempo"].toString(),
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Precisión"],
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            result["Errores"].toString(),
                            style: TextStyle(color: rowColor),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
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
                          """
📅 Fecha:
La fecha en que se registró el resultado.

⚙️ Dificultad:
El nivel de dificultad del test, donde 1 es el más fácil y 5 es el más difícil.

🏆 Puntuación:
El porcentaje de respuestas correctas.

⏱️ Tiempo (s):
El tiempo promedio que tardaste en responder cada pregunta.

🎯 Precisión:
El porcentaje de respuestas correctas respecto al total de intentos.

❌ Errores:
El número de errores cometidos en esta sesión.

💡 Resultados destacados:
- En verde se muestran los resultados con 100% de precisión.
- En rojo se muestran los resultados con más de 3 errores o 0% de precisión.
""",
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
        ),
      ],
    );
  }
}

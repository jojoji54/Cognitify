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
      "Universitario": "4.0",
      "FP": "3.0",
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
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildLineChart(),
            const SizedBox(height: 20),
            _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final averageScore =
        results.expand((r) => r.scores).reduce((a, b) => a + b) /
            results.expand((r) => r.scores).length;
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
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            lineBarsData: [
              // Datos del Usuario
              LineChartBarData(
                spots: results
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.scores.last,
                        ))
                    .toList(),
                isCurved: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
                color: const Color.fromARGB(255, 80, 39, 176),
              ),
              // Datos del Dataset
              LineChartBarData(
                spots: List.generate(
                  datasetScores.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    datasetScores[index],
                  ),
                ),
                isCurved: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                color: const Color.fromARGB(255, 120, 120, 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: const Text("📋 Aquí irá la tabla de resultados detallados."),
    );
  }
}

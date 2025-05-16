import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:cognitify/models/test_result.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MemorySequenceResults extends StatefulWidget {
  const MemorySequenceResults({Key? key}) : super(key: key);

  @override
  State<MemorySequenceResults> createState() => _MemorySequenceResultsState();
}

class _MemorySequenceResultsState extends State<MemorySequenceResults> {
  late List<TestResult> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final resultsBox = await Hive.openBox<TestResult>('resultsBox');
    setState(() {
      results = resultsBox.values
          .where((r) => r.testName == "Secuencia de Números")
          .toList();
      isLoading = false;
    });
  }

  double _calculateAverageScore() {
    if (results.isEmpty) return 0.0;
    final totalScore = results
        .map((result) => result.scores.last)
        .reduce((a, b) => a + b);
    return totalScore / results.length;
  }

  double _calculateAverageResponseTime() {
    if (results.isEmpty) return 0.0;
    final totalDuration = results
        .map((result) => result.durations.last.inSeconds)
        .reduce((a, b) => a + b);
    return totalDuration / results.length;
  }

  double _calculateAccuracy() {
    if (results.isEmpty) return 0.0;
    final totalCorrect = results.where((r) => r.scores.last == 100.0).length;
    return (totalCorrect / results.length) * 100;
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

    final averageScore = _calculateAverageScore();
    final averageResponseTime = _calculateAverageResponseTime();
    final accuracy = _calculateAccuracy();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(averageScore, averageResponseTime, accuracy),
          const SizedBox(height: 20),
          _buildLineChart(),
          const SizedBox(height: 20),
          _buildDetailedResultsTable(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double averageScore, double averageResponseTime, double accuracy) {
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
            "Puntuación Promedio: ${averageScore.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
          ),
          Text(
            "Tiempo de Respuesta Promedio: ${averageResponseTime.toStringAsFixed(2)} segundos",
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
            "Total de Pruebas: ${results.length}",
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "📈 Evolución del Rendimiento",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
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
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResultsTable() {
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
            "📋 Detalles de los Resultados",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 20),
          ...results.take(10).map((result) {
            final date = result.date.toLocal().toString().split(' ')[0];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -4,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  color: NeumorphicTheme.baseColor(context),
                ),
                padding: const EdgeInsets.all(15),
                child: Text(
                  "📅 $date | 🏆 ${result.scores.last.toStringAsFixed(2)} puntos | ⏱️ ${result.durations.last.inSeconds} seg",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 80, 80, 80),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

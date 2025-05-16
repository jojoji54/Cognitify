// lib/widgets/results_card.dart
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/info_card.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';

class ResultsCard extends StatefulWidget {
  final String testName;

  const ResultsCard({Key? key, required this.testName}) : super(key: key);

  @override
  _ResultsCardState createState() => _ResultsCardState();
}

class _ResultsCardState extends State<ResultsCard> {
  List<TestResult> results = [];
  bool hasResults = false;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  void loadResults() {
    final resultsBox = Hive.box<TestResult>('resultsBox');
    final filteredResults = resultsBox.values
        .where((result) => result.testName == widget.testName)
        .toList();

    setState(() {
      results = filteredResults;
      hasResults = filteredResults.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasResults) {
      // Muestra el InfoCard si no hay resultados
      return const InfoCard();
    }

    // Muestra los resultados si existen
    return Column(
      children: results.map((result) {
        final averageScore = result.averageScore(lastN: 10).toStringAsFixed(2);
        final averageDuration =
            result.averageDuration(lastN: 10).inSeconds.toString();
        final lastResult = result.rawData.last;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: 8,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              color: NeumorphicTheme.baseColor(context),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5027B0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Puntuación Promedio\n(últimos 10): $averageScore",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 47, 47, 47),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tiempo Promedio (últimos 10): $averageDuration s",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 80, 80, 80),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Última Dificultad: ${lastResult['sequenceLength']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 80, 80, 80),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Último Intento: ${lastResult['userInput']} / ${lastResult['expected']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 120, 120, 120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

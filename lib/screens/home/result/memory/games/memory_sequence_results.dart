// lib/screens/results/games/memory_sequence_results.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:cognitify/models/test_result.dart';

class MemorySequenceResults extends StatelessWidget {
  const MemorySequenceResults({Key? key}) : super(key: key);

  Future<List<TestResult>> _loadResults() async {
    final resultsBox = await Hive.openBox<TestResult>('resultsBox');
    return resultsBox.values
        .where((r) => r.testName == "Secuencia de Números")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TestResult>>(
      future: _loadResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];
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

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Neumorphic(
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
                  "Resultados - Secuencia de Números",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                ),
                const SizedBox(height: 20),
                ...results.map((result) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4,
                        boxShape:
                            NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                        color: NeumorphicTheme.baseColor(context),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Fecha: ${result.date}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 47, 47, 47),
                            ),
                          ),
                          Text(
                            "Puntuación: ${result.scores.last.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 80, 80, 80),
                            ),
                          ),
                          Text(
                            "Duración: ${result.durations.last.inSeconds} segundos",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 80, 80, 80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

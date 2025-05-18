import 'package:cognitify/screens/dataset_selection_screen.dart';
import 'package:cognitify/screens/test_execution/memory/games/cards/card_pairs_game.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/secuence_of_numbers.dart';
import 'package:cognitify/services/preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class MemoryTestTypeSelection extends StatelessWidget {
  const MemoryTestTypeSelection({Key? key}) : super(key: key);

  void navigateToTest(
      BuildContext context, String testName, Widget testWidget) async {
    HapticFeedback.lightImpact();
    final hasDataset = await PreferencesService.isDatasetSelected(testName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            hasDataset ? testWidget : DatasetSelectionScreen(),
      ),
    );
  }

  Widget buildTestButton(BuildContext context, String title, IconData icon,
      String testName, Widget testWidget) {
    return NeumorphicButton(
      onPressed: () => navigateToTest(context, testName, testWidget),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        depth: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 30, color: const Color.fromARGB(255, 80, 39, 176)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 20, color: Color.fromARGB(255, 150, 150, 150)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Tipos de Pruebas de Memoria",
          style: const NeumorphicStyle(
            depth: 8,
            intensity: 0.8,
            color: Colors.black,
          ),
          textStyle: NeumorphicTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            buildTestButton(
              context,
              "Secuencia de Números",
              Icons.numbers,
              "Secuencia de numeros",
              const SequenceOfNumbers(),
            ),
            const SizedBox(height: 20),
            buildTestButton(
              context,
              "Parejas de Cartas",
              Icons.apps,
              "Pareja de cartas",
              const CardPairsGame(),
            ),
            const SizedBox(height: 20),
            buildTestButton(
              context,
              "Memoria Espacial",
              Icons.grid_view,
              "Memoria Espacial",
              const CardPairsGame(), // Ajusta esto cuando tengas el widget correcto
            ),
          ],
        ),
      ),
    );
  }
}

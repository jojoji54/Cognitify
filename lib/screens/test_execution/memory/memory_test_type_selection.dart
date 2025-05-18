import 'package:cognitify/screens/dataset_selection_screen.dart';
import 'package:cognitify/screens/test_execution/memory/games/cards/card_pairs_game.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/secuence_of_numbers.dart';
import 'package:cognitify/services/preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in_left.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MemoryTestTypeSelection extends StatefulWidget {
  const MemoryTestTypeSelection({Key? key}) : super(key: key);

  @override
  State<MemoryTestTypeSelection> createState() =>
      _MemoryTestTypeSelectionState();
}

class _MemoryTestTypeSelectionState extends State<MemoryTestTypeSelection> {
  String? selectedTest;

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
    final isSelected = selectedTest == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: NeumorphicButton(
        onPressed: () {
          setState(() {
            selectedTest = title;
          });
        },
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          depth: isSelected ? -6 : 6,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon,
                      size: 25,
                      color: isSelected
                          ? const Color.fromARGB(255, 40, 85, 42)
                          : const Color.fromARGB(255, 80, 39, 176)),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color.fromARGB(255, 40, 85, 42)
                          : const Color.fromARGB(255, 47, 47, 47),
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 20,
                  color: isSelected
                      ? const Color.fromARGB(255, 40, 85, 42)
                      : const Color.fromARGB(255, 150, 150, 150)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDescriptionCard(BuildContext context, String title) {
    final icon = title == "Secuencia de Números"
        ? FontAwesomeIcons.listOl
        : title == "Parejas de Cartas"
            ? FontAwesomeIcons.clone
            : FontAwesomeIcons.mapLocationDot;

    return FadeIn(
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 6,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          color: NeumorphicTheme.baseColor(context),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5027B0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 170,
                  child: Text(
                    getDescription(title),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 80, 80, 80),
                    ),
                  ),
                ),
              ],
            ),
            NeumorphicButton(
              onPressed: () => navigateToTest(
                context,
                title,
                title == "Secuencia de Números"
                    ? const SequenceOfNumbers()
                    : title == "Parejas de Cartas"
                        ? const CardPairsGame()
                        : const CardPairsGame(),
              ),
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
                depth: 6,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                child: Text(
                  ">",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                ),
              ),
            ),
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
            buildTestButton(
              context,
              "Secuencia de Números",
              FontAwesomeIcons.listOl,
              "Secuencia de numeros",
              const SequenceOfNumbers(),
            ),
            buildTestButton(
              context,
              "Parejas de Cartas",
              FontAwesomeIcons.clone,
              "Pareja de cartas",
              const CardPairsGame(),
            ),
            buildTestButton(
              context,
              "Memoria Espacial",
              FontAwesomeIcons.mapLocationDot,
              "Memoria Espacial",
              const CardPairsGame(), // Ajusta esto cuando tengas el widget correcto
            ),
            const SizedBox(height: 30),
            if (selectedTest != null) ...[
              FadeInLeft(
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 47, 47, 47),
                    ),
                  ),
                ),
              ),
              buildDescriptionCard(context, selectedTest!),
            ],
          ],
        ),
      ),
    );
  }

  String getDescription(String title) {
    switch (title) {
      case "Secuencia de Números":
        return "Mide tu capacidad para recordar secuencias numéricas de forma precisa y rápida, evaluando tanto memoria a corto plazo como velocidad de procesamiento.";
      case "Parejas de Cartas":
        return "Evalúa tu memoria de reconocimiento, concentración y capacidad para encontrar relaciones visuales rápidamente.";
      case "Memoria Espacial":
        return "Mide tu capacidad para recordar ubicaciones y patrones espaciales, esencial para tareas de navegación y orientación.";
      default:
        return "";
    }
  }
}

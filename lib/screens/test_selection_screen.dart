import 'package:cognitify/screens/dataset_selection_screen.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/secuence_of_numbers.dart';
import 'package:cognitify/screens/test_execution/memory/memory_test_type_selection.dart';
import 'package:cognitify/services/preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  String? selectedTest;
  int? indexs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Pruebas Cognitivas",
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                buildTestButton(context, "Memoria", Icons.memory, 0),
                const SizedBox(height: 20),
                buildTestButton(context, "Atención", Icons.visibility, 1),
                const SizedBox(height: 20),
                buildTestButton(
                    context, "Razonamiento", Icons.lightbulb_outline, 2),
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
                  FadeIn(
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        depth: 6,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(16)),
                        color: NeumorphicTheme.baseColor(context),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5027B0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(
                                      selectedTest == "Memoria"
                                          ? Icons.memory
                                          : selectedTest == "Atención"
                                              ? Icons.visibility
                                              : Icons.lightbulb_outline,
                                      size: 30,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 170,
                                  child: Text(
                                    getDescription(selectedTest!),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 80, 80, 80),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: NeumorphicButton(
                                  onPressed: () async {
                                    /* final box = await Hive.openBox<DatasetInfo>(
                                        'datasetsBox');

                                    // Obtener solo datasets de secuencia
                                    final secuenciaDatasets = box.values
                                        .where((dataset) =>
                                            dataset.subtype == "Secuencia")
                                        .toList(); */
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => indexs == 0
                                            ? const MemoryTestTypeSelection()
                                            : const MemoryTestTypeSelection(),
                                      ),
                                    );
                                  },
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(50)),
                                    depth: 6,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 3),
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeInUp(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 120,
                  height: 120,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/book.json',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTestButton(
      BuildContext context, String title, IconData icon, int index) {
    return NeumorphicButton(
      onPressed: () {
        HapticFeedback.lightImpact;
        setState(() {
          selectedTest = title;
          indexs = index;
        });
      },
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

  String getDescription(String title) {
    switch (title) {
      case "Memoria":
        return "Pruebas diseñadas para medir tu capacidad de recordar y reconocer patrones.";
      case "Atención":
        return "Evalúa tu capacidad para concentrarte y filtrar distracciones.";
      case "Razonamiento":
        return "Mide tu capacidad para resolver problemas y tomar decisiones.";
      default:
        return "";
    }
  }
}

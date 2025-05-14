import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class SequenceOfNumbers extends StatefulWidget {
  const SequenceOfNumbers({Key? key}) : super(key: key);

  @override
  State<SequenceOfNumbers> createState() => _SequenceOfNumbersState();
}

class _SequenceOfNumbersState extends State<SequenceOfNumbers> {
  List<int> sequence = [];
  int currentStep = 0;
  bool testStarted = false;
  bool showInput = false;
  String userInput = "";
  int sequenceLength = 5;
  bool showInfo = false;

  @override
  void initState() {
    super.initState();
    loadDifficulty();
    generateSequence();
  }

  void generateSequence() {
    final random = Random();
    sequence = List.generate(sequenceLength, (_) => random.nextInt(10));
  }

   Future<void> saveDifficulty(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sequenceLength', length);
  }

  Future<void> loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sequenceLength = prefs.getInt('sequenceLength') ?? 5;
    });
  }

  void startTest() {
    setState(() {
      testStarted = true;
      showInfo = false;
      currentStep = 0;
      userInput = "";
      showInput = false;
      generateSequence();

      // Tiempo dinámico basado en la dificultad
      int displayTime =
          (15 - sequenceLength) * 200; // Ajusta este valor si es muy rápido

      Future.delayed(Duration(milliseconds: displayTime), () {
        setState(() {
          showInput = true;
        });
      });
    });
  }

  void checkAnswer() {
    if (userInput == sequence.join("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Correcto!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Incorrecto. Era: ${sequence.join("")}"),
        ),
      );
    }
    setState(() {
      testStarted = false;
      showInput = false;
      userInput = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Test de Memoria",
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!testStarted && !showInfo) ...[
                  NeumorphicButton(
                    onPressed: startTest,
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(16)),
                      depth: 6,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Iniciar Prueba",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 47, 47, 47),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Selecciona la dificultad",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 47, 47, 47),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: -4,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(16)),
                      color: NeumorphicTheme.baseColor(context),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        const Text(
                          "Dificultad",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                        Slider(
                          value: sequenceLength.toDouble(),
                          min: 3,
                          max: 12,
                          divisions: 9,
                          label: sequenceLength.toString(),
                          onChanged: (value) {
                            setState(() {
                              sequenceLength = value.toInt();
                              saveDifficulty(sequenceLength);
                              generateSequence();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ] else if (showInfo) ...[
                  FadeIn(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 6,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(16)),
                          color: NeumorphicTheme.baseColor(context),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          "En esta prueba se te mostrará una secuencia de números durante unos segundos. Luego tendrás que ingresarla en el mismo orden. La dificultad se puede ajustar usando el control deslizante para aumentar o disminuir la longitud de la secuencia.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else if (testStarted && !showInput) ...[
                  FadeIn(
                    child: Text(
                      sequence.join(" "),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 80, 39, 176),
                      ),
                    ),
                  ),
                ] else if (showInput) ...[
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 6,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(16)),
                      color: NeumorphicTheme.baseColor(context),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          userInput.isEmpty
                              ? "Selecciona la secuencia..."
                              : userInput,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(10, (number) {
                            return NeumorphicButton(
                              onPressed: () {
                                if (userInput.length < sequence.length) {
                                  setState(() {
                                    userInput += number.toString();
                                  });
                                }
                              },
                              style: NeumorphicStyle(
                                depth: 6,
                                boxShape: NeumorphicBoxShape.circle(),
                                color: NeumorphicTheme.baseColor(context),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                number.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 80, 39, 176),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: NeumorphicButton(
                                onPressed: () {
                                  setState(() {
                                    userInput = "";
                                  });
                                },
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(16)),
                                  depth: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                child: const Text(
                                  "Borrar",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 47, 47, 47),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: NeumorphicButton(
                                onPressed: () {
                                  checkAnswer();
                                },
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(16)),
                                  depth: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                child: const Text(
                                  "Verificar",
                                  textAlign: TextAlign.center,
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
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!testStarted)
            Positioned(
              bottom: 20,
              right: 20,
              child: NeumorphicButton(
                onPressed: () {
                  setState(() {
                    showInfo = !showInfo;
                  });
                },
                style: const NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 6,
                ),
                padding: const EdgeInsets.all(15),
                child: Icon(
                  showInfo ? Icons.close : Icons.info_outline,
                  size: 30,
                  color: const Color.fromARGB(255, 80, 39, 176),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

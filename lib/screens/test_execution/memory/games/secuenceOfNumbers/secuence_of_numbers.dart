import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/difficulty_slider.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/info_card.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/input_pad.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/neumorphic_app_bar.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/results_card.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/sequence_display.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/start_button.dart';
import 'package:cognitify/utils/test_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SequenceOfNumbers extends StatefulWidget {
  const SequenceOfNumbers({Key? key}) : super(key: key);

  @override
  State<SequenceOfNumbers> createState() => _SequenceOfNumbersState();
}

class _SequenceOfNumbersState extends State<SequenceOfNumbers> {
  DateTime? startTime;
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
      startTime = DateTime.now();

      int displayTime = (15 - sequenceLength) * 200;
      Future.delayed(Duration(milliseconds: displayTime), () {
        setState(() {
          showInput = true;
        });
      });
    });
  }

  void checkAnswer() {
    try {
      final startTime = DateTime.now();

    // Calcula si la secuencia es correcta
    bool isCorrect = userInput == sequence.join("");
    final duration = DateTime.now().difference(startTime);
    int errors = isCorrect ? 0 : sequence.length - userInput.length;
    double score =
        isCorrect ? 100.0 : (userInput.length / sequence.length) * 100.0;

    // Datos sin procesar para guardar en Hive
    final rawData = {
      "sequenceLength": sequenceLength,
      "userInput": userInput,
      "expected": sequence.join(""),
      "errors": errors,
      "responseTime": duration.inMilliseconds,
      "difficulty": sequenceLength,
      "correct": isCorrect,
    };

    // Guarda el resultado
    Constant.saveTestResult(
        "Secuencia de Números", score, duration, rawData, sequenceLength);

    // Muestra el resultado al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect
            ? "✅ Correcto! Puntuación: $score"
            : "❌ Incorrecto. Era: ${sequence.join("")}"),
      ),
    );

    // Reinicia el estado del juego
    setState(() {
      testStarted = false;
      showInput = false;
      userInput = "";
    });
      
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Algo ha ido mal :("),
      ),
    );
    } 
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNeumorphicAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!testStarted && !showInfo) StartButton(onStart: startTest),
                if (!testStarted && !showInfo) ...[
                  DifficultySlider(
                    sequenceLength: sequenceLength,
                    onDifficultyChanged: (length) {
                      setState(() {
                        sequenceLength = length;
                        saveDifficulty(sequenceLength);
                        generateSequence();
                      });
                    },
                  ),
                ],
                if (showInfo) ...[
                  const ResultsCard(testName: "Secuencia de Números"),
                ],
                if (testStarted && !showInput)
                  SequenceDisplay(sequence: sequence),
                if (showInput)
                  InputPad(
                    sequenceLength: sequence.length,
                    userInput: userInput,
                    onInputChange: (newInput) {
                      setState(() {
                        userInput = newInput;
                      });
                    },
                    onClear: () {
                      setState(() {
                        userInput = "";
                      });
                    },
                    onCheck: checkAnswer,
                  ),
              ],
            ),
          ),
          if (!testStarted)
            Positioned(
              bottom: 20,
              right: 20,
              child: IconButton(
                icon: Icon(
                  showInfo ? Icons.close : Icons.info_outline,
                  size: 30,
                  color: const Color.fromARGB(255, 80, 39, 176),
                ),
                onPressed: () {
                  setState(() {
                    showInfo = !showInfo;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

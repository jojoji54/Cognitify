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

      // ✅ Registra el tiempo de inicio aquí, no en checkAnswer
      startTime = DateTime.now();

      int displayTime = (15 - sequenceLength) * 200;
      Future.delayed(Duration(milliseconds: displayTime), () {
        setState(() {
          showInput = true;
        });
      });
    });
  }

  double calculateScore(String userInput, String expectedSequence,
      Duration duration, int difficulty) {
    int correctLength = 0;
    int errors = 0;

    print("🔍 Iniciando cálculo de puntuación...");
    print("📝 Secuencia Esperada: $expectedSequence");
    print("📝 Secuencia del Usuario: $userInput");
    print("🕒 Duración: ${duration.inSeconds} segundos");
    print("🧩 Dificultad: $difficulty");

    // Calcula la precisión
    for (int i = 0; i < userInput.length; i++) {
      if (i < expectedSequence.length && userInput[i] == expectedSequence[i]) {
        correctLength++;
      } else {
        errors++;
      }
    }

    print("✅ Caracteres correctos: $correctLength");
    print("❌ Errores: $errors");

    // Penalización por errores
    double accuracyScore = (correctLength / expectedSequence.length) * 100;
    accuracyScore -= errors * 5;
    print("🎯 Puntuación de Precisión: $accuracyScore");

    // Penalización por tiempo (más balanceada)
    int maxTime = difficulty * 2;
    double timePenalty = (duration.inSeconds / maxTime) * 50.0;
    timePenalty =
        timePenalty.clamp(0, 50); // Limita la penalización máxima a 50 puntos
    print("⏱️ Penalización por Tiempo: $timePenalty");

    // Calcula la puntuación final sin escalar
    double finalScore = accuracyScore - timePenalty;
    print("📝 Puntuación sin escalar: $finalScore");

    // Asegura que no sea negativo
    finalScore = finalScore.clamp(0, 100);
    print("🏁 Puntuación Final: $finalScore");

    return finalScore;
  }

  void checkAnswer() {
    try {
      if (startTime == null) {
        print("❌ Error: El tiempo de inicio no está registrado.");
        return;
      }

      // Calcula si la secuencia es correcta
      final duration = DateTime.now().difference(startTime!);
      final isCorrect = userInput == sequence.join("");
      final score = calculateScore(
          userInput, sequence.join(""), duration, sequenceLength);

      // Datos sin procesar para guardar en Hive
      final rawData = {
        "sequenceLength": sequenceLength,
        "userInput": userInput,
        "expected": sequence.join(""),
        "errors": sequence.length - userInput.length,
        "responseTime": duration.inMilliseconds,
        "difficulty": sequenceLength,
        "correct": isCorrect,
      };

      // Logs detallados
      print("🔍 Iniciando cálculo de puntuación...");
      print("📝 Secuencia Esperada: ${sequence.join("")}");
      print("📝 Secuencia del Usuario: $userInput");
      print("🕒 Duración: ${duration.inMilliseconds} ms");
      print("🧩 Dificultad: $sequenceLength");
      print("✅ Secuencia Correcta: $isCorrect");
      print("📊 Puntuación Calculada: ${score.toStringAsFixed(2)}");
      print("📝 Datos sin procesar: $rawData");

      // Guarda el resultado
      Constant.saveTestResult(
          "Secuencia de Números", score, duration, rawData, sequenceLength);

      // Muestra el resultado al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCorrect
              ? "✅ Correcto! Puntuación: ${score.toStringAsFixed(2)}"
              : "❌ Incorrecto. Era: ${sequence.join("")}"),
        ),
      );

      // Reinicia el estado del juego
      setState(() {
        testStarted = false;
        showInput = false;
        userInput = "";
        startTime = null; // Resetea el tiempo para el siguiente intento
      });

      print("✅ Resultado guardado correctamente.");
    } catch (e) {
      print("❌ Error al guardar el resultado: $e");
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

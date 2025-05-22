import 'dart:async';
import 'dart:math';
import 'package:cognitify/models/test_result.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/difficulty_slider.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/neumorphic_app_bar.dart';
import 'package:cognitify/utils/test_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpatialMemoryGame extends StatefulWidget {
  const SpatialMemoryGame({super.key});

  @override
  State<SpatialMemoryGame> createState() => _SpatialMemoryGameState();
}

class _SpatialMemoryGameState extends State<SpatialMemoryGame> {
  List<Map<String, dynamic>> tiles = [];
  List<int> targetSequence = [];
  List<int> userSequence = [];
  int gridSize = 3;
  int errors = 0;
  bool gameStarted = false;
  bool isDisplayingSequence = false;
  DateTime? startTime;
  int sessionNumber = 1;
  String userId = "R1003P";
  bool? showSpaces;

  @override
  void initState() {
    super.initState();
    loadDifficulty();
    showSpaces=false;
  }

  Future<void> saveDifficulty(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spatialMemorySize', size);
  }

  Future<void> loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gridSize = prefs.getInt('spatialMemorySize') ?? 3;
    });
  }

  void startGame() {
    final int totalTiles = gridSize * gridSize;
    final random = Random();
    final available = List.generate(totalTiles, (index) => index);

    tiles = List.generate(
        totalTiles,
        (i) => {
              "index": i,
              "isShown": false,
              "color": Colors.grey,
            });

    targetSequence = [];
    for (int i = 0; i < gridSize; i++) {
      final idx = available.removeAt(random.nextInt(available.length));
      targetSequence.add(idx);
    }

    userSequence.clear();
    errors = 0;
    gameStarted = true;
    isDisplayingSequence = true;
    startTime = DateTime.now();

    setState(() {});
    showSequence();
  }

  Future<void> showSequence() async {
    showSpaces=true;
    for (int i = 0; i < targetSequence.length; i++) {
      int index = targetSequence[i];

      setState(() {
        tiles[index]["isShown"] = true;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() {
          tiles[index]["isShown"] = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      isDisplayingSequence = false;
    });
  }

  void handleTileTap(int index) {
    if (!gameStarted || isDisplayingSequence) return;
    if (userSequence.contains(index)) return;

    setState(() {
      tiles[index]["isShown"] = true;
    });

    userSequence.add(index);

    if (index != targetSequence[userSequence.length - 1]) {
      errors++;
    }

    if (userSequence.length == targetSequence.length) {
      final duration = DateTime.now().difference(startTime!);
      saveResult(duration);
    }
  }

  void saveResult(Duration duration) {
    double score = 100.0;
    score -= errors * 10;
    score -= duration.inSeconds * 2;
    score = score.clamp(0, 500);

    final rawData = {
      "onset": startTime != null
          ? DateTime.now().millisecondsSinceEpoch -
              startTime!.millisecondsSinceEpoch
          : 0,
      "duration": duration.inMilliseconds,
      "trial_type": "SEQUENCE",
      "response_time": duration.inMilliseconds,
      "errors": errors,
      "score": score,
      "max_score": 500,
      "difficulty": gridSize,
      "experiment": "SPATIAL_MEMORY",
      "session": sessionNumber,
      "subject": userId,
      "answer": errors == 0 ? 1 : -1,
    };

    Constant.saveTestResult(
        "Memoria Espacial", score, duration, rawData, gridSize);
    TestResult.saveGlobalStats(score, gridSize, errors, duration);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors == 0
              ? "🏆 ¡Secuencia completada correctamente!"
              : "🔁 Secuencia completada con errores ($errors)",
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: errors == 0 ? Colors.green : Colors.orange,
      ),
    );

    setState(() {
      gameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNeumorphicAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!gameStarted)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text("Comenzar"),
                  ),
                  DifficultySlider(
                    sequenceLength: gridSize,
                    onDifficultyChanged: (val) {
                      setState(() {
                        gridSize = val;
                        saveDifficulty(val);
                      });
                    },
                  )
                ],
              ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: gridSize,
                children: List.generate(tiles.length, (index) {
                  final tile = tiles[index];
                  final isShown = tile["isShown"] == true;

                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: NeumorphicButton(
                      onPressed: () => handleTileTap(index),
                      style: NeumorphicStyle(
                        depth: isShown ? -6 : 6,
                        disableDepth: isDisplayingSequence ? false : true,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12)),
                        color: isShown ? Colors.blue : null,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:cognitify/screens/test_execution/memory/games/cards/widget/card_grid.dart';
import 'package:cognitify/screens/test_execution/memory/games/cards/widget/card_info_card.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/difficulty_slider.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/start_button.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/neumorphic_app_bar.dart';
import 'package:cognitify/utils/test_constants.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cognitify/models/test_result.dart';

class CardPairsGame extends StatefulWidget {
  const CardPairsGame({Key? key}) : super(key: key);

  @override
  State<CardPairsGame> createState() => _CardPairsGameState();
}

class _CardPairsGameState extends State<CardPairsGame> {
  DateTime? startTime;
  int cardPairs = 5;
  int errors = 0;
  bool gameStarted = false;
  bool showInfo = false;
  List<Map<String, dynamic>> cards = [];
  List<int> selectedIndexes = [];
  int attempts = 0;
  int matchedPairs = 0;
  Timer? gameTimer;
  int gameTime = 0;
  int sessionNumber = 1;
  String userId = "R1002P";
  double? finalScore;

  @override
  void initState() {
    super.initState();
    loadDifficulty();
  }

  Future<void> saveDifficulty(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cardPairs', length);
  }

  Future<void> loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cardPairs = prefs.getInt('cardPairs') ?? 5;
    });
  }

  void startGame() {
    final List<IconData> icons = [
      FontAwesomeIcons.apple,
      FontAwesomeIcons.car,
      FontAwesomeIcons.bell,
      FontAwesomeIcons.coffee,
      FontAwesomeIcons.dog,
      FontAwesomeIcons.fish,
      FontAwesomeIcons.gift,
      FontAwesomeIcons.heart,
      FontAwesomeIcons.laptop,
      FontAwesomeIcons.sun,
      FontAwesomeIcons.star,
      FontAwesomeIcons.user,
    ];

    cards = [...icons.take(cardPairs), ...icons.take(cardPairs)]
        .map((icon) => {"icon": icon, "revealed": false, "matched": false})
        .toList();
    cards.shuffle();

    setState(() {
      gameStarted = true;
      attempts = 0;
      matchedPairs = 0;
      errors = 0;
      gameTime = 0;
      startTime = DateTime.now();
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          gameTime++;
        });
      }
    });
  }

  void stopGame() {
    if (gameTimer != null && gameTimer!.isActive) {
      gameTimer!.cancel();
      print("🕒 Tiempo total de juego: $gameTime segundos");
    }
  }

  double calculatePairScore(int pairs, int attempts, Duration duration,
      int difficulty, int errors, int matchedPairs) {
    print("🔍 Calculando puntuación para el juego de parejas...");

    // Puntuación base
    double baseScore = 100.0 + (pairs - 5) * 20.0;

    // Penalización por intentos
    int maxAttempts = pairs * 2;
    double attemptPenalty = (attempts - pairs) * 2.0;
    attemptPenalty = attemptPenalty.clamp(0, 100);

    // Penalización por tiempo
    int maxTime = difficulty * 15;
    double timePenalty = (duration.inSeconds / maxTime) * 100.0;
    timePenalty = timePenalty.clamp(0, 100);

    // Bonificación por velocidad
    double speedBonus = (pairs * 20) - (duration.inSeconds / (pairs * 2)) * 100;
    speedBonus = speedBonus.clamp(0, 100);

    // Penalización por errores
    double errorPenalty = errors * 5.0;
    errorPenalty = errorPenalty.clamp(0, 100);

    // Bonificación por dificultad
    double difficultyBonus = difficulty * 5.0;
    difficultyBonus = difficultyBonus.clamp(0, 100);

    // Puntuación final (máximo 500 puntos)
    double finalScore = baseScore -
        attemptPenalty -
        timePenalty -
        errorPenalty +
        speedBonus +
        difficultyBonus;
    finalScore = finalScore.clamp(0, 500);

    print("🏁 Puntuación Final: $finalScore");
    this.finalScore = finalScore;
    return finalScore;
  }

  void savePairResult(int pairs, int attempts, Duration duration,
      int difficulty, int firstIndex, int secondIndex) {
    try {
      final score = calculatePairScore(
          pairs, attempts, duration, difficulty, errors, matchedPairs);

      final onset = startTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;

      final rawData = {
        "onset": onset,
        "duration": duration.inMilliseconds,
        "sample": attempts,
        "trial_type": "PAIR",
        "response_time": duration.inMilliseconds,
        "serialpos": firstIndex,
        "probepos": secondIndex,
        "study_1": pairs,
        "study_2": matchedPairs,
        "list": cardPairs,
        "errors": errors,
        "score": score,
        "max_score": 500,
        "difficulty": difficulty,
        "experiment": "PAIR_GAME",
        "session": sessionNumber,
        "subject": userId,
      };

      Constant.saveTestResult(
          "Parejas de Cartas", score, duration, rawData, difficulty);
      TestResult.saveGlobalStats(score, difficulty, errors, duration);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "🏆 ¡Juego completado! Puntuación: ${score.toStringAsFixed(2)} / 500"),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      print("✅ Resultado de Parejas de Cartas guardado correctamente.");
    } catch (e) {
      print("❌ Error al guardar el resultado: $e");
    }
  }

  void _onCardTap(int index) {
    if (selectedIndexes.length == 2) return;

    setState(() {
      cards[index]["revealed"] = true;
      selectedIndexes.add(index);

      if (selectedIndexes.length == 2) {
        attempts++;
        final firstIndex = selectedIndexes[0];
        final secondIndex = selectedIndexes[1];

        Future.delayed(const Duration(milliseconds: 500), () {
          if (cards[firstIndex]["icon"] == cards[secondIndex]["icon"]) {
            cards[firstIndex]["matched"] = true;
            cards[secondIndex]["matched"] = true;
            matchedPairs++;
            final duration = DateTime.now().difference(startTime!);
            savePairResult(cardPairs, attempts, duration, cardPairs, firstIndex,
                secondIndex);
          } else {
            cards[firstIndex]["revealed"] = false;
            cards[secondIndex]["revealed"] = false;
            errors++;
          }

          selectedIndexes.clear();
          setState(() {});
        });
      }
    });
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
                if (!gameStarted && !showInfo) StartButton(onStart: startGame),
                if (!gameStarted && !showInfo)
                  DifficultySlider(
                    sequenceLength: cardPairs,
                    onDifficultyChanged: (length) {
                      setState(() {
                        cardPairs = length;
                        saveDifficulty(cardPairs);
                      });
                    },
                  ),
                if (showInfo)
                  const CardInfoCard(
                    title: "Cómo Jugar",
                    content:
                        "Encuentra todas las parejas lo más rápido posible. Cuanto más difícil, más puntos puedes ganar.",
                  ),
                if (gameStarted)
                  CardGrid(
                    cards: cards,
                    onCardTap: _onCardTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

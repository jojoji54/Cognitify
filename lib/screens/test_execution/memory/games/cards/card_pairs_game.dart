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
  double totalScore = 0.0; // 🔄 Acumula el puntaje total

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

    // 🔢 Puntuación base
    double baseScore = 100.0 + (pairs - 5) * 20.0;

    // 📝 Penalización por intentos
    int maxAttempts = pairs * 2;
    double attemptPenalty = (attempts - pairs) * 2.0;
    attemptPenalty = attemptPenalty.clamp(0, 100);
    print("📝 Penalización por Intentos: $attemptPenalty");

    // ⏱️ Penalización por tiempo (balanceada)
    int maxTime =
        pairs * 3 * difficulty; // Ajustado para dificultad y cantidad de pares
    double timePenalty = (duration.inMilliseconds / maxTime) * 100.0;
    timePenalty = timePenalty.clamp(0, 100);
    print("⏱️ Penalización por Tiempo: $timePenalty");

    // 🚀 Bonificación por velocidad (más precisa)
    double expectedTimePerPair =
        (maxTime / pairs) / 2; // Tiempo esperado por par
    double speedBonus =
        (expectedTimePerPair - (duration.inMilliseconds / pairs)) * 2;
    speedBonus = speedBonus.clamp(0, 50);
    print("🚀 Bonificación por Velocidad: $speedBonus");

    // ❌ Penalización por errores (ajustada)
    double errorPenalty = errors * 5.0;
    errorPenalty = errorPenalty.clamp(0, 100);
    print("❌ Penalización por Errores: $errorPenalty");

    // 💥 Bonificación por dificultad (ajustada)
    double difficultyBonus = difficulty * 10.0;
    difficultyBonus = difficultyBonus.clamp(0, 100);
    print("💥 Bonificación por Dificultad: $difficultyBonus");

    // 🏁 Puntuación final (máximo 500 puntos)
    double finalScore = baseScore -
        attemptPenalty -
        timePenalty -
        errorPenalty +
        speedBonus +
        difficultyBonus;
    finalScore = finalScore.clamp(0, 500);

    print("🏁 Puntuación Final: $finalScore");
    finalScore = finalScore;
    return finalScore;
  }

  void savePairResult(int pairs, int attempts, Duration duration,
      int difficulty, int firstIndex, int secondIndex, bool matched) {
    try {
      final score = calculatePairScore(
          pairs, attempts, duration, difficulty, errors, matchedPairs);

      // 🔄 Acumula el puntaje total
      totalScore += score;

      // Datos sin procesar para Hive
      final rawData = {
        "onset": startTime != null
            ? DateTime.now().millisecondsSinceEpoch -
                startTime!.millisecondsSinceEpoch
            : 0,
        "duration": duration.inMilliseconds,
        "sample": attempts,
        "trial_type": matched ? "PAIR" : "PROB",
        "response_time": duration.inMilliseconds,
        "serialpos": firstIndex,
        "probepos": secondIndex,
        "probe_word": cards[firstIndex]["icon"].toString(),
        "resp_word": cards[secondIndex]["icon"].toString(),
        "stim_file": "icon_${cards[firstIndex]["icon"].toString()}",
        "study_1": pairs,
        "study_2": matchedPairs,
        "list": sessionNumber,
        "errors": errors,
        "score": score,
        "max_score": 500,
        "difficulty": difficulty,
        "experiment": "PAIR_GAME",
        "session": sessionNumber,
        "subject": userId,
        "answer": matched ? 1 : -1,
      };

      Constant.saveTestResult(
          "Parejas de Cartas", score, duration, rawData, difficulty);
      TestResult.saveGlobalStats(score, difficulty, errors, duration);

      // 🔔 Muestra el mensaje solo si se han encontrado todos los pares
      if (matchedPairs == pairs) {
        stopGame();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🏆 ¡Juego completado!\nPuntuación Total: ${totalScore.toStringAsFixed(2)} / ${pairs * 500}",
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // 🔄 Reinicia el puntaje total para la próxima partida
        totalScore = 0.0;
      }

      print("✅ Resultado de Parejas de Cartas guardado correctamente.");
    } catch (e) {
      print("❌ Error al guardar el resultado: $e");
    }
  }

  void _onCardTap(int index) {
    // Ignora si ya hay dos cartas seleccionadas
    if (selectedIndexes.length == 2 || cards[index]["matched"]) return;

    setState(() {
      // Revela la carta seleccionada
      cards[index]["revealed"] = true;
      selectedIndexes.add(index);

      // Verifica si se han seleccionado dos cartas
      if (selectedIndexes.length == 2) {
        attempts++;
        final firstIndex = selectedIndexes[0];
        final secondIndex = selectedIndexes[1];

        Future.delayed(const Duration(milliseconds: 500), () {
          final isMatch =
              cards[firstIndex]["icon"] == cards[secondIndex]["icon"];

          if (isMatch) {
            // Marca las cartas como emparejadas
            cards[firstIndex]["matched"] = true;
            cards[secondIndex]["matched"] = true;
            matchedPairs++;
          } else {
            // Oculta las cartas si no coinciden
            cards[firstIndex]["revealed"] = false;
            cards[secondIndex]["revealed"] = false;
            errors++;
          }

          // Guarda el resultado del intento
          final duration = DateTime.now().difference(startTime!);
          savePairResult(
            cardPairs,
            attempts,
            duration,
            cardPairs,
            firstIndex,
            secondIndex,
            isMatch,
          );

          // Reinicia el estado de las cartas seleccionadas
          selectedIndexes.clear();

          // Refresca el estado del widget
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

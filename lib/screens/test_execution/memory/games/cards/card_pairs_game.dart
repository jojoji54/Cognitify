// lib/screens/test_execution/memory/games/cardPairs/card_pairs_game.dart
import 'package:cognitify/screens/test_execution/memory/games/cards/widget/card_grid.dart';
import 'package:cognitify/screens/test_execution/memory/games/cards/widget/card_info_card.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/difficulty_slider.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/start_button.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/widgets/neumorphic_app_bar.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CardPairsGame extends StatefulWidget {
  const CardPairsGame({Key? key}) : super(key: key);

  @override
  State<CardPairsGame> createState() => _CardPairsGameState();
}

class _CardPairsGameState extends State<CardPairsGame> {
  DateTime? startTime;
  int cardPairs = 5;
  bool gameStarted = false;
  bool showInfo = false;
  List<Map<String, dynamic>> cards = [];
  List<int> selectedIndexes = [];
  int attempts = 0;

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

    // Mezcla las cartas
    cards = [...icons.take(cardPairs), ...icons.take(cardPairs)]
        .map((icon) => {"icon": icon, "revealed": false, "matched": false})
        .toList();
    cards.shuffle();

    setState(() {
      gameStarted = true;
      attempts = 0;
      startTime = DateTime.now();
    });
  }

  void _onCardTap(int index) {
    setState(() {
      cards[index]["revealed"] = true;
      selectedIndexes.add(index);

      if (selectedIndexes.length == 2) {
        Future.delayed(const Duration(milliseconds: 500), () {
          final firstIndex = selectedIndexes[0];
          final secondIndex = selectedIndexes[1];

          if (cards[firstIndex]["icon"] == cards[secondIndex]["icon"]) {
            // Marca como emparejadas
            cards[firstIndex]["matched"] = true;
            cards[secondIndex]["matched"] = true;
          } else {
            // Oculta las cartas si no coinciden
            cards[firstIndex]["revealed"] = false;
            cards[secondIndex]["revealed"] = false;
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
                if (!gameStarted && !showInfo)
                  StartButton(onStart: startGame),
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
                        "Encuentra todas las parejas de cartas lo más rápido posible. Cuanto más difícil, más puntos puedes ganar.",
                  ),
                if (gameStarted)
                  CardGrid(
                    cards: cards,
                    onCardTap: _onCardTap,
                  ),
              ],
            ),
          ),
          if (!gameStarted)
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

// lib/screens/games/card_pairs_game.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

class CardPairsGameb extends StatefulWidget {
  const CardPairsGameb({Key? key}) : super(key: key);

  @override
  State<CardPairsGameb> createState() => _CardPairsGamebState();
}

class _CardPairsGamebState extends State<CardPairsGameb> {
  List<Map<String, dynamic>> cards = [];
  List<int> selectedIndexes = [];
  DateTime? startTime;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final List<IconData> icons = [
      FontAwesomeIcons.apple,
      FontAwesomeIcons.car,
      FontAwesomeIcons.bell,
      FontAwesomeIcons.coffee,
      FontAwesomeIcons.dog,
      FontAwesomeIcons.fish,
      FontAwesomeIcons.gift,
      FontAwesomeIcons.heart,
    ];

    // Duplica y mezcla las cartas
    cards = [...icons, ...icons]
        .map((icon) => {"icon": icon, "revealed": false, "matched": false})
        .toList();
    cards.shuffle();

    // Reinicia el tiempo y los intentos
    setState(() {
      startTime = DateTime.now();
      attempts = 0;
    });
  }

  void _onCardTap(int index) {
    setState(() {
      // Revela la carta
      cards[index]["revealed"] = true;
      selectedIndexes.add(index);

      // Si se han seleccionado dos cartas, verifica si son pareja
      if (selectedIndexes.length == 2) {
        Future.delayed(const Duration(seconds: 1), () {
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
      appBar: NeumorphicAppBar(
        title: const Text("Parejas de Cartas"),
        centerTitle: true,
      ),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return NeumorphicButton(
              onPressed: card["matched"] || selectedIndexes.contains(index)
                  ? null
                  : () => _onCardTap(index),
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                depth: card["revealed"] || card["matched"] ? -6 : 6,
                color: card["matched"]
                    ? const Color.fromARGB(255, 120, 200, 120)
                    : NeumorphicTheme.baseColor(context),
              ),
              child: Center(
                child: card["revealed"] || card["matched"]
                    ? Icon(card["icon"], size: 30, color: Colors.black)
                    : const Icon(Icons.question_mark, size: 30, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

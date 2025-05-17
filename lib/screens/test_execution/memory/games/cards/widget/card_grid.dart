// lib/screens/test_execution/memory/games/cardPairs/widgets/card_grid.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';

class CardGrid extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final Function(int) onCardTap;

  const CardGrid({
    Key? key,
    required this.cards,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final isRevealed = card["revealed"];
          final isMatched = card["matched"];
          final isDisabled = isRevealed || isMatched;

          return NeumorphicButton(
            onPressed: isDisabled ? null : () => onCardTap(index),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
              depth: isDisabled ? -6 : 6,
              color: isMatched
                  ? const Color.fromARGB(255, 120, 200, 120)
                  : NeumorphicTheme.baseColor(context),
            ),
            child: Center(
              child: isRevealed || isMatched
                  ? Icon(card["icon"], size: 30, color: Colors.black)
                  : const Icon(Icons.question_mark, size: 30, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

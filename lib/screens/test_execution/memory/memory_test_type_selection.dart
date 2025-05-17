import 'package:cognitify/screens/test_execution/memory/games/cards/card_pairs_game.dart';
import 'package:cognitify/screens/test_execution/memory/games/secuenceOfNumbers/secuence_of_numbers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class MemoryTestTypeSelection extends StatelessWidget {
  const MemoryTestTypeSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Tipos de Pruebas de Memoria",
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SequenceOfNumbers()),
                );
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.numbers,
                            size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Secuencia de Números",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 20, color: Color.fromARGB(255, 150, 150, 150)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CardPairsGame()),
                );
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apps,
                            size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Parejas de Cartas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 20, color: Color.fromARGB(255, 150, 150, 150)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {},
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.grid_view,
                            size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Memoria Espacial",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 20, color: Color.fromARGB(255, 150, 150, 150)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

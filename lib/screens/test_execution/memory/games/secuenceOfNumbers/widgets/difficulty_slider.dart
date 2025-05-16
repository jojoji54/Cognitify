import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class DifficultySlider extends StatelessWidget {
  final int sequenceLength;
  final ValueChanged<int> onDifficultyChanged;

  const DifficultySlider({
    Key? key,
    required this.sequenceLength,
    required this.onDifficultyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Selecciona la dificultad",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Neumorphic(
          style: NeumorphicStyle(
            depth: -4,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            color: NeumorphicTheme.baseColor(context),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  onDifficultyChanged(value.toInt());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

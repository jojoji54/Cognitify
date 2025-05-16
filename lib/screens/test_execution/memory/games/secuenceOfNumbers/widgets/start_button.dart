import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class StartButton extends StatelessWidget {
  final VoidCallback onStart;

  const StartButton({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onStart,
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        depth: 6,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "Iniciar Prueba",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 47, 47, 47),
          ),
        ),
      ),
    );
  }
}

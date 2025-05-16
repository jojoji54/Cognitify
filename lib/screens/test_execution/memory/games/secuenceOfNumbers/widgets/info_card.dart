import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: const Text(
        "En esta prueba se te mostrará una secuencia de números durante unos segundos. Luego tendrás que ingresarla en el mismo orden. La dificultad se puede ajustar usando el control deslizante.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 47, 47, 47),
        ),
      ),
    );
  }
}

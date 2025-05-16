import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class InputPad extends StatelessWidget {
  final int sequenceLength;
  final String userInput;
  final ValueChanged<String> onInputChange;
  final VoidCallback onClear;
  final VoidCallback onCheck;

  const InputPad({
    Key? key,
    required this.sequenceLength,
    required this.userInput,
    required this.onInputChange,
    required this.onClear,
    required this.onCheck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Muestra la secuencia que el usuario ha ingresado
          Text(
            userInput.isEmpty ? "Selecciona la secuencia..." : userInput,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 47, 47, 47),
            ),
          ),
          const SizedBox(height: 10),

          // Teclado numérico
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(10, (number) {
              return NeumorphicButton(
                onPressed: () {
                  if (userInput.length < sequenceLength) {
                    onInputChange(userInput + number.toString());
                  }
                },
                style: NeumorphicStyle(
                  depth: 6,
                  boxShape: NeumorphicBoxShape.circle(),
                  color: NeumorphicTheme.baseColor(context),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 39, 176),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Botones de Borrar y Verificar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: onClear,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                    depth: 6,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: const Text(
                    "Borrar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 47, 47, 47),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: NeumorphicButton(
                  onPressed: onCheck,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                    depth: 6,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: const Text(
                    "Verificar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 47, 47, 47),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

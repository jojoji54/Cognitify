import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_animator/flutter_animator.dart';

class SequenceDisplay extends StatelessWidget {
  final List<int> sequence;

  const SequenceDisplay({Key? key, required this.sequence}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Text(
        sequence.join(" "),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 80, 39, 176),
        ),
      ),
    );
  }
}

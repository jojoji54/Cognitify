
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class TestSelectionScreen extends StatelessWidget {
  const TestSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Pruebas Cognitivas",
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
              onPressed: () {},
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.memory, size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Memoria",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20, color: Color.fromARGB(255, 150, 150, 150)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {},
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Atención",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20, color: Color.fromARGB(255, 150, 150, 150)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () {},
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                depth: 6,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 30, color: Color.fromARGB(255, 80, 39, 176)),
                        SizedBox(width: 10),
                        Text(
                          "Razonamiento",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20, color: Color.fromARGB(255, 150, 150, 150)),
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


import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  String? selectedTest;

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
            buildTestButton(context, "Memoria", Icons.memory),
            const SizedBox(height: 20),
            buildTestButton(context, "Atención", Icons.visibility),
            const SizedBox(height: 20),
            buildTestButton(context, "Razonamiento", Icons.lightbulb_outline),
            const SizedBox(height: 30),
            if (selectedTest != null) ...[
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 6,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  color: NeumorphicTheme.baseColor(context),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          selectedTest == "Memoria" ? Icons.memory :
                          selectedTest == "Atención" ? Icons.visibility :
                          Icons.lightbulb_outline,
                          size: 40,
                          color: const Color.fromARGB(255, 80, 39, 176),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          selectedTest!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      getDescription(selectedTest!),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 80, 80, 80),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: NeumorphicButton(
                        onPressed: () {},
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                          depth: 6,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text(
                            "Go",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 47, 47, 47),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTestButton(BuildContext context, String title, IconData icon) {
    return NeumorphicButton(
      onPressed: () {
        setState(() {
          selectedTest = title;
        });
      },
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        depth: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: const Color.fromARGB(255, 80, 39, 176)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Color.fromARGB(255, 150, 150, 150)),
          ],
        ),
      ),
    );
  }

  String getDescription(String title) {
    switch (title) {
      case "Memoria":
        return "Pruebas diseñadas para medir tu capacidad de recordar y reconocer patrones.";
      case "Atención":
        return "Evalúa tu capacidad para concentrarte y filtrar distracciones.";
      case "Razonamiento":
        return "Mide tu capacidad para resolver problemas y tomar decisiones.";
      default:
        return "";
    }
  }
}

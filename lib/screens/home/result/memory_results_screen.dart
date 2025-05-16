// lib/screens/results/memory_results_screen.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class MemoryResultsScreen extends StatefulWidget {
  const MemoryResultsScreen({Key? key}) : super(key: key);

  @override
  State<MemoryResultsScreen> createState() => _MemoryResultsScreenState();
}

class _MemoryResultsScreenState extends State<MemoryResultsScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> memoryGames = [
    {"name": "Secuencia de Números", "icon": "🔢"},
    {"name": "Parejas de Cartas", "icon": "🃏"},
    {"name": "Memoria Espacial", "icon": "🗺️"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Resultados - Memoria",
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: memoryGames.length,
              itemBuilder: (context, index) {
                final game = memoryGames[index];
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 6,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                      color: NeumorphicTheme.baseColor(context),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Resultados de ${game['name']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 47, 47, 47),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Aquí mostraremos las estadísticas y gráficos del juego.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          PageViewDotIndicator(
            currentItem: _currentPage,
            count: memoryGames.length,
            unselectedColor: const Color.fromARGB(255, 150, 150, 150),
            selectedColor: const Color.fromARGB(255, 80, 39, 176),
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

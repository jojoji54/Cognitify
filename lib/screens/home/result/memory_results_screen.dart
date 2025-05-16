// lib/screens/results/memory_results_screen.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';

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
          // Barra de navegación superior
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: memoryGames.length,
              itemBuilder: (context, index) {
                final game = memoryGames[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentPage = index;
                      _pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color.fromARGB(255, 80, 39, 176)
                          : NeumorphicTheme.baseColor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color: const Color.fromARGB(255, 80, 39, 176).withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      "${game['icon']} ${game['name']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _currentPage == index
                            ? Colors.white
                            : const Color.fromARGB(255, 47, 47, 47),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
        ],
      ),
    );
  }
}

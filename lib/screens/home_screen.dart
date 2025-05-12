import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> _valueNotifier0 = ValueNotifier(0);
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Cognitify",
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
        centerTitle: false,
        actions: [
          NeumorphicButton(
            onPressed: () {},
            style: const NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 4,
            ),
            child: const Icon(
              Icons.settings,
              size: 24,
              color: Color.fromARGB(255, 80, 39, 176),
            ),
          ),
        ],
      ),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: const NeumorphicBoxShape.circle(),
                    depth: 8,
                    intensity: 0.8,
                    color: NeumorphicTheme.baseColor(context),
                  ),
                  child: Container(
                    width: 250,
                    height: 250,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/neuron.json',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {},
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8)),
                      depth: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.play_circle_fill,
                                  size: 30,
                                  color: Color.fromARGB(255, 80, 39, 176)),
                              SizedBox(width: 10),
                              Text(
                                "Resultados",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 47, 47, 47),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: DashedCircularProgressBar.aspectRatio(
                              aspectRatio: 0.5, // width ÷ height
                              valueNotifier: _valueNotifier0,
                              progress: 30,
                              maxProgress: 100,
                              corners: StrokeCap.butt,
                              foregroundColor: Color.fromARGB(255, 80, 39, 176),
                              backgroundColor:
                                  const Color.fromARGB(255, 194, 190, 190),
                              foregroundStrokeWidth: 5,
                              backgroundStrokeWidth: 5,
                              animation: true,
                              child: Center(
                                child: ValueListenableBuilder(
                                  valueListenable: _valueNotifier0,
                                  builder: (_, double value, __) => Text(
                                    '${value.toInt()}%',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {},
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8)),
                      depth: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bar_chart,
                                  size: 30,
                                  color: Color.fromARGB(255, 80, 39, 176)),
                              SizedBox(width: 10),
                              Text(
                                "Resultados",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 47, 47, 47),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: DashedCircularProgressBar.aspectRatio(
                              aspectRatio: 0.5, // width ÷ height
                              valueNotifier: _valueNotifier,
                              progress: 50,
                              maxProgress: 100,
                              corners: StrokeCap.butt,
                              foregroundColor: Color.fromARGB(255, 80, 39, 176),
                              backgroundColor:
                                  const Color.fromARGB(255, 194, 190, 190),
                              foregroundStrokeWidth: 5,
                              backgroundStrokeWidth: 5,
                              animation: true,
                              child: Center(
                                child: ValueListenableBuilder(
                                  valueListenable: _valueNotifier,
                                  builder: (_, double value, __) => Text(
                                    '${value.toInt()}%',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

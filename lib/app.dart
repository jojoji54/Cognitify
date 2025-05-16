import 'package:cognitify/screens/home/home_screen.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class CognitifyApp extends StatelessWidget {
   CognitifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NeumorphicApp(
      title: 'Cognitify',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFE0E0E0),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF2E3239),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: HomeScreen(),
    );
  }
}



import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class CustomNeumorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNeumorphicAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicAppBar(
        title: NeumorphicText(
          "Test de Memoria",
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
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// lib/widgets/category_buttons.dart
import 'package:cognitify/models/user_profile.dart';
import 'package:cognitify/screens/home/result/memory/memory_results_screen.dart';
import 'package:cognitify/screens/profile/user_profile_screen.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';

class CategoryButtons extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoryButtons({Key? key, required this.onCategorySelected})
      : super(key: key);

  Future<bool> _userProfileExists() async {
    final profileBox = Hive.box<UserProfile>('userBox');
    return profileBox.isNotEmpty;
  }

  void _handleCategorySelection(BuildContext context, String category) async {
    final hasProfile = await _userProfileExists();

    if (hasProfile) {
      // Si ya hay perfil, abrir los resultados
      if (category == "Memoria") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemoryResultsScreen()),
        );
      }
      // Aquí puedes añadir las otras categorías como Atención y Razonamiento
    } else {
      // Si no hay perfil, ir a la pantalla de registro de usuario
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Row(
        children: [
          _buildCategoryButton(context, Icons.memory, "Memoria", Colors.purple),
          const SizedBox(width: 5),
          _buildCategoryButton(
              context, Icons.visibility, "Atención", Colors.blue),
          const SizedBox(width: 5),
          _buildCategoryButton(
              context, Icons.lightbulb_outline, "Razonamiento", Colors.green),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, IconData icon, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NeumorphicButton(
          onPressed: () => _handleCategorySelection(context, label),
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            depth: 6,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Icon(icon, size: 30, color: color),
          ),
        ),
      ),
    );
  }
}

// lib/screens/user_profile_screen.dart
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';
import 'package:cognitify/models/user_profile.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _educationLevel;
  String? _language;
  String? _maritalStatus;
  String? _cognitiveStatus;
  String? _physicalActivity;
  String? _gender;

  final List<String> languages = ["Español", "Inglés", "Francés", "Alemán", "Otro"];
  final List<String> maritalStatuses = ["Soltero", "Casado", "Divorciado", "Viudo", "Otro"];
  final List<String> cognitiveStatuses = ["Normal", "Deterioro Cognitivo Leve", "Demencia", "Otro"];
  final List<String> physicalActivityLevels = ["Sedentario", "Ligero", "Moderado", "Intenso"];
  final List<String> educationLevels = ["Primaria", "Secundaria", "Bachillerato","FP", "Universitario", "Postgrado", "Otro"];
  final List<String> genders = ["Masculino", "Femenino", "Otro"];

  void saveProfile() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    if (name.isEmpty ||
        age <= 0 ||
        _educationLevel == null ||
        _language == null ||
        _maritalStatus == null ||
        _cognitiveStatus == null ||
        _physicalActivity == null ||
        _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos obligatorios."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final userProfile = UserProfile(
      name: name,
      age: age,
      educationLevel: _educationLevel!,
      createdAt: DateTime.now(),
      nativeLanguage: _language!,
      maritalStatus: _maritalStatus!,
      cognitiveStatus: _cognitiveStatus!,
      physicalActivityLevel: _physicalActivity!,
      gender: _gender!,
    );

    final userBox = await Hive.openBox<UserProfile>('userBox');
    userBox.put('profile', userProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Perfil guardado correctamente."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Perfil del Usuario",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField("Nombre (obligatorio)", _nameController),
              const SizedBox(height: 15),
              buildTextField("Edad (obligatorio)", _ageController, isNumeric: true),
              const SizedBox(height: 15),
              buildDropdownField("Nivel de Educación (obligatorio)", educationLevels, (value) => _educationLevel = value),
              const SizedBox(height: 15),
              buildDropdownField("Género (obligatorio)", genders, (value) => _gender = value),
              const SizedBox(height: 15),
              buildDropdownField("Idioma Nativo (obligatorio)", languages, (value) => _language = value),
              const SizedBox(height: 15),
              buildDropdownField("Estado Civil (obligatorio)", maritalStatuses, (value) => _maritalStatus = value),
              const SizedBox(height: 15),
              buildDropdownField("Estado Cognitivo (obligatorio)", cognitiveStatuses, (value) => _cognitiveStatus = value),
              const SizedBox(height: 15),
              buildDropdownField("Nivel de Actividad Física (obligatorio)", physicalActivityLevels, (value) => _physicalActivity = value),
              const SizedBox(height: 30),
              NeumorphicButton(
                onPressed: saveProfile,
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  depth: 6,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Guardar Perfil",
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
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller, {bool isNumeric = false}) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 47, 47, 47),
        ),
      ),
    );
  }

  Widget buildDropdownField(String hint, List<String> options, ValueChanged<String?> onChanged) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        hint: Text(hint),
        value: null,
        onChanged: onChanged,
        items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
      ),
    );
  }
}

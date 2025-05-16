// lib/models/user_profile.dart
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String educationLevel;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  String? nativeLanguage;

  @HiveField(5)
  String? maritalStatus;

  @HiveField(6)
  String? cognitiveStatus;

  @HiveField(7)
  String? physicalActivityLevel;

  @HiveField(8)
  String? gender;  // Añadimos el género

  UserProfile({
    required this.name,
    required this.age,
    required this.educationLevel,
    required this.createdAt,
    this.nativeLanguage,
    this.maritalStatus,
    this.cognitiveStatus,
    this.physicalActivityLevel,
    this.gender,  // Nuevo campo
  });
}

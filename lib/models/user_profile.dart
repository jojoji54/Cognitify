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

  UserProfile({
    required this.name,
    required this.age,
    required this.educationLevel,
    required this.createdAt,
  });
}

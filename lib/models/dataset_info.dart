import 'package:hive/hive.dart';

part 'dataset_info.g.dart';

@HiveType(typeId: 3)
class DatasetInfo extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String url;

  @HiveField(2)
  String type; // Memoria, Atención, Razonamiento, etc.

  @HiveField(3)
  DateTime dateAdded;

  DatasetInfo({
    required this.name,
    required this.url,
    required this.type,
    required this.dateAdded,
  });
}

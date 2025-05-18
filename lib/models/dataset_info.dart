// lib/models/dataset_info.dart
import 'package:hive/hive.dart';

part 'dataset_info.g.dart';

@HiveType(typeId: 3)
class DatasetInfo extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String url;

  @HiveField(2)
  String type;

  @HiveField(3)
  String subtype;

  @HiveField(4)
  DateTime dateAdded;

  @HiveField(5)
  DateTime? lastUpdated;

  @HiveField(6)
  List<Map<String, dynamic>>?
      jsonData; // Aquí se guarda el CSV convertido a JSON

  DatasetInfo({
    required this.name,
    required this.url,
    required this.type,
    required this.subtype,
    required this.dateAdded,
    this.lastUpdated,
    this.jsonData,
  });
}

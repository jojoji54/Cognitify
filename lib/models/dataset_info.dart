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
  DateTime dateAdded;

  @HiveField(4)
  DateTime? lastUpdated; // Nueva propiedad para la fecha de actualización

  DatasetInfo({
    required this.name,
    required this.url,
    required this.type,
    required this.dateAdded,
    this.lastUpdated,
  });
}

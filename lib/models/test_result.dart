import 'package:hive/hive.dart';

part 'test_result.g.dart';

@HiveType(typeId: 0)
class TestResult extends HiveObject {
  @HiveField(0)
  String testName;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double score;

  @HiveField(3)
  Duration duration;

  @HiveField(4)
  Map<String, dynamic> rawData;

  TestResult({
    required this.testName,
    required this.date,
    required this.score,
    required this.duration,
    required this.rawData,
  });
}
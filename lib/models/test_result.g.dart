// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestResultAdapter extends TypeAdapter<TestResult> {
  @override
  final int typeId = 0;

  @override
  TestResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResult(
      testName: fields[0] as String,
      date: fields[1] as DateTime,
      scores: (fields[2] as List).cast<double>(),
      durations: (fields[3] as List).cast<Duration>(),
      rawData: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, TestResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.testName)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.scores)
      ..writeByte(3)
      ..write(obj.durations)
      ..writeByte(4)
      ..write(obj.rawData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DatasetInfoAdapter extends TypeAdapter<DatasetInfo> {
  @override
  final int typeId = 3;

  @override
  DatasetInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DatasetInfo(
      name: fields[0] as String,
      url: fields[1] as String,
      type: fields[2] as String,
      subtype: fields[3] as String,
      dateAdded: fields[4] as DateTime,
      lastUpdated: fields[5] as DateTime?,
      jsonData: (fields[6] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, DatasetInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.subtype)
      ..writeByte(4)
      ..write(obj.dateAdded)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.jsonData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatasetInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

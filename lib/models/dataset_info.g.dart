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
      dateAdded: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DatasetInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dateAdded);
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

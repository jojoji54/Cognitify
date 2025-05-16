// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      age: fields[1] as int,
      educationLevel: fields[2] as String,
      createdAt: fields[3] as DateTime,
      nativeLanguage: fields[4] as String?,
      maritalStatus: fields[5] as String?,
      cognitiveStatus: fields[6] as String?,
      physicalActivityLevel: fields[7] as String?,
      gender: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.educationLevel)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.nativeLanguage)
      ..writeByte(5)
      ..write(obj.maritalStatus)
      ..writeByte(6)
      ..write(obj.cognitiveStatus)
      ..writeByte(7)
      ..write(obj.physicalActivityLevel)
      ..writeByte(8)
      ..write(obj.gender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tank.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TankAdapter extends TypeAdapter<Tank> {
  @override
  final int typeId = 0;

  @override
  Tank read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tank(
      name: fields[0] as String,
      waterType: fields[1] as String,
      color: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Tank obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.waterType)
      ..writeByte(2)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TankAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

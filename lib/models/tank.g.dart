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
      sizeInGallons: fields[3] as int,
      fishKeys: (fields[4] as List).cast<int>(),
      invertebrateKeys: (fields[5] as List).cast<int>(),
      plantKeys: (fields[6] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tank obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.waterType)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.sizeInGallons)
      ..writeByte(4)
      ..write(obj.fishKeys)
      ..writeByte(5)
      ..write(obj.invertebrateKeys)
      ..writeByte(6)
      ..write(obj.plantKeys);
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

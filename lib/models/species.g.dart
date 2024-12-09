// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpeciesAdapter extends TypeAdapter<Species> {
  @override
  final int typeId = 7;

  @override
  Species read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Species(
      name: fields[0] as String,
      scientificName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Species obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.scientificName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeciesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

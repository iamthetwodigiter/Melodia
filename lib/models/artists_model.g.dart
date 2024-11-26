// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artists_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtistsAdapter extends TypeAdapter<Artists> {
  @override
  final int typeId = 3;

  @override
  Artists read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artists(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String?,
      images: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      type: fields[4] as String,
      url: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Artists obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongsAdapter extends TypeAdapter<Songs> {
  @override
  final int typeId = 4;

  @override
  Songs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Songs(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      year: fields[3] as String,
      duration: fields[4] as int,
      explicitContent: fields[5] as bool,
      language: fields[6] as String,
      hasLyrics: fields[7] as bool,
      image: fields[8] as String,
      downloadUrl: fields[9] as String,
      artists: (fields[10] as List).cast<Artists>(),
      albumTitle: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Songs obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.explicitContent)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.hasLyrics)
      ..writeByte(8)
      ..write(obj.image)
      ..writeByte(9)
      ..write(obj.downloadUrl)
      ..writeByte(10)
      ..write(obj.artists)
      ..writeByte(11)
      ..write(obj.albumTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

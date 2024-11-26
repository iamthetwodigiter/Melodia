// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlists_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistsAdapter extends TypeAdapter<Playlists> {
  @override
  final int typeId = 2;

  @override
  Playlists read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlists(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      year: fields[3] as int?,
      language: fields[4] as String?,
      explicitContent: fields[5] as bool,
      url: fields[6] as String,
      songCount: fields[7] as int?,
      artists: (fields[8] as List).cast<Artists>(),
      image: fields[9] as String,
      songs: (fields[10] as List).cast<Songs>(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlists obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.explicitContent)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.songCount)
      ..writeByte(8)
      ..write(obj.artists)
      ..writeByte(9)
      ..write(obj.image)
      ..writeByte(10)
      ..write(obj.songs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

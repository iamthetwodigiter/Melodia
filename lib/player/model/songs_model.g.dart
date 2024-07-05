// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 0;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      link: fields[0] as String,
      id: fields[1] as String,
      name: fields[2] as String,
      duration: fields[3] as String,
      imageUrl: fields[4] as String,
      artists: (fields[5] as List).cast<String>(),
      playlistData: fields[6] as Playlist?,
      index: fields[7] as int,
      shuffleMode: fields[8] as bool,
      playlistName: fields[9] as String,
      year: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.link)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.artists)
      ..writeByte(6)
      ..write(obj.playlistData)
      ..writeByte(7)
      ..write(obj.index)
      ..writeByte(8)
      ..write(obj.shuffleMode)
      ..writeByte(9)
      ..write(obj.playlistName)
      ..writeByte(10)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

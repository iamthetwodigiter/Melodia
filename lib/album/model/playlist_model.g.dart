// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      idList: (fields[0] as List).cast<String>(),
      linkList: (fields[1] as List).cast<String>(),
      imageUrlList: (fields[2] as List).cast<String>(),
      nameList: (fields[3] as List).cast<String>(),
      artistsList: (fields[4] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList(),
      durationList: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idList)
      ..writeByte(1)
      ..write(obj.linkList)
      ..writeByte(2)
      ..write(obj.imageUrlList)
      ..writeByte(3)
      ..write(obj.nameList)
      ..writeByte(4)
      ..write(obj.artistsList)
      ..writeByte(5)
      ..write(obj.durationList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

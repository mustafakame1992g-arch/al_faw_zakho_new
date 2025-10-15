// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsModelAdapter extends TypeAdapter<NewsModel> {
  @override
  final int typeId = 1;

  @override
  NewsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsModel(
      id: fields[0] as String,
      titleAr: fields[1] as String,
      titleEn: fields[2] as String,
      contentAr: fields[3] as String,
      contentEn: fields[4] as String,
      imagePath: fields[5] as String,
      publishDate: fields[6] as DateTime,
      author: fields[7] as String,
      category: fields[8] as String,
      isBreaking: fields[9] as bool,
      viewCount: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titleAr)
      ..writeByte(2)
      ..write(obj.titleEn)
      ..writeByte(3)
      ..write(obj.contentAr)
      ..writeByte(4)
      ..write(obj.contentEn)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.publishDate)
      ..writeByte(7)
      ..write(obj.author)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isBreaking)
      ..writeByte(10)
      ..write(obj.viewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

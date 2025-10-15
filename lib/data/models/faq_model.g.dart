// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaqModelAdapter extends TypeAdapter<FaqModel> {
  @override
  final int typeId = 4;

  @override
  FaqModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaqModel(
      id: fields[0] as String,
      questionAr: fields[1] as String,
      questionEn: fields[2] as String,
      answerAr: fields[3] as String,
      answerEn: fields[4] as String,
      category: fields[5] as String,
      importance: fields[6] as int,
      tags: (fields[7] as List).cast<String>(),
      createdAt: fields[8] as DateTime,
      viewCount: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FaqModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questionAr)
      ..writeByte(2)
      ..write(obj.questionEn)
      ..writeByte(3)
      ..write(obj.answerAr)
      ..writeByte(4)
      ..write(obj.answerEn)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.importance)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.viewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaqModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

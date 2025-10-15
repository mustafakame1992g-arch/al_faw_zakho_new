// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CandidateModelAdapter extends TypeAdapter<CandidateModel> {
  @override
  final int typeId = 3;

  @override
  CandidateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CandidateModel(
      id: fields[0] as String,
      nameAr: fields[1] as String,
      nameEn: fields[2] as String,
      nicknameAr: fields[3] as String,
      nicknameEn: fields[4] as String,
      positionAr: fields[5] as String,
      positionEn: fields[6] as String,
      bioAr: fields[7] as String,
      bioEn: fields[8] as String,
      imagePath: fields[9] as String,
      phoneNumber: fields[10] as String,
      province: fields[11] as String,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CandidateModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameAr)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.nicknameAr)
      ..writeByte(4)
      ..write(obj.nicknameEn)
      ..writeByte(5)
      ..write(obj.positionAr)
      ..writeByte(6)
      ..write(obj.positionEn)
      ..writeByte(7)
      ..write(obj.bioAr)
      ..writeByte(8)
      ..write(obj.bioEn)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.phoneNumber)
      ..writeByte(11)
      ..write(obj.province)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

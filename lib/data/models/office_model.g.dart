// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'office_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfficeModelAdapter extends TypeAdapter<OfficeModel> {
  @override
  final int typeId = 2;

  @override
  OfficeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfficeModel(
      id: fields[0] as String,
      nameAr: fields[1] as String,
      nameEn: fields[2] as String,
      addressAr: fields[3] as String,
      addressEn: fields[4] as String,
      phoneNumber: fields[5] as String,
      secondaryPhone: fields[6] as String?,
      email: fields[7] as String,
      managerNameAr: fields[8] as String,
      managerNameEn: fields[9] as String,
      latitude: fields[10] as double,
      longitude: fields[11] as double,
      province: fields[12] as String,
      district: fields[13] as String,
      workingHours: fields[14] as String,
      workingDays: fields[15] as String?,
      isActive: fields[16] as bool,
      capacity: fields[17] as int,
      services: (fields[18] as List).cast<String>(),
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      notes: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfficeModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameAr)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.addressAr)
      ..writeByte(4)
      ..write(obj.addressEn)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.secondaryPhone)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.managerNameAr)
      ..writeByte(9)
      ..write(obj.managerNameEn)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.province)
      ..writeByte(13)
      ..write(obj.district)
      ..writeByte(14)
      ..write(obj.workingHours)
      ..writeByte(15)
      ..write(obj.workingDays)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.capacity)
      ..writeByte(18)
      ..write(obj.services)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfficeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_usage_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUsageDataAdapter extends TypeAdapter<AppUsageData> {
  @override
  final int typeId = 1;

  @override
  AppUsageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsageData(
      appName: fields[0] as String,
      batteryUsed: fields[1] as double,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsageData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.appName)
      ..writeByte(1)
      ..write(obj.batteryUsed)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

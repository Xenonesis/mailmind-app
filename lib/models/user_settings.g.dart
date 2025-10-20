// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isDarkMode: fields[0] as bool,
      aiModel: fields[1] as String,
      syncFrequency: fields[2] as int,
      enableNotifications: fields[3] as bool,
      autoSync: fields[4] as bool,
      language: fields[5] as String,
      enableSummaries: fields[6] as bool,
      enableCategorization: fields[7] as bool,
      enablePriorityDetection: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.aiModel)
      ..writeByte(2)
      ..write(obj.syncFrequency)
      ..writeByte(3)
      ..write(obj.enableNotifications)
      ..writeByte(4)
      ..write(obj.autoSync)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.enableSummaries)
      ..writeByte(7)
      ..write(obj.enableCategorization)
      ..writeByte(8)
      ..write(obj.enablePriorityDetection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

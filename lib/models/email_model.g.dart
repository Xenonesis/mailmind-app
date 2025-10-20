// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailAdapter extends TypeAdapter<Email> {
  @override
  final int typeId = 1;

  @override
  Email read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Email(
      id: fields[0] as String,
      subject: fields[1] as String,
      sender: fields[2] as String,
      senderEmail: fields[3] as String,
      recipients: (fields[4] as List).cast<String>(),
      body: fields[5] as String,
      htmlBody: fields[6] as String?,
      receivedAt: fields[7] as DateTime,
      category: fields[8] as String,
      priority: fields[9] as String,
      summary: fields[10] as String?,
      isRead: fields[11] as bool,
      isImportant: fields[12] as bool,
      attachments: (fields[13] as List?)?.cast<String>(),
      threadId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Email obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.senderEmail)
      ..writeByte(4)
      ..write(obj.recipients)
      ..writeByte(5)
      ..write(obj.body)
      ..writeByte(6)
      ..write(obj.htmlBody)
      ..writeByte(7)
      ..write(obj.receivedAt)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.summary)
      ..writeByte(11)
      ..write(obj.isRead)
      ..writeByte(12)
      ..write(obj.isImportant)
      ..writeByte(13)
      ..write(obj.attachments)
      ..writeByte(14)
      ..write(obj.threadId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Simple catalog of services offered to employees
@immutable
class Service {
  const Service({required this.id, required this.title, required this.description});
  final String id;
  final String title;
  final String description;
}

// Predefined demo services (can be replaced by API later)
const List<Service> kDemoServices = [
  Service(
    id: 'sick_leave',
    title: 'Оформление больничного',
    description: 'Заявка на подтверждение и выплату больничного листа.',
  ),
  Service(
    id: 'vacation',
    title: 'Отпуск',
    description: 'Оформление отпуска с указанием дат и типа.',
  ),
  Service(
    id: 'child_support',
    title: 'Поддержка семьи',
    description: 'Матпомощь, ДМС, детские выплаты и т.п.',
  ),
];

@HiveType(typeId: 1)
enum RequestStatus {
  @HiveField(0)
  submitted,
  @HiveField(1)
  inReview,
  @HiveField(2)
  approved,
  @HiveField(3)
  rejected
}

@HiveType(typeId: 3)
enum Role {
  @HiveField(0)
  user,
  @HiveField(1)
  moderator,
  @HiveField(2)
  adminUserManager, // выдаёт логины/пароли
  @HiveField(3)
  adminSuper, // отвечает за всё остальное
  @HiveField(4)
  support, // чат-поддержка
}

@HiveType(typeId: 4)
class AppUser {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String login;
  @HiveField(2)
  final String displayName;
  @HiveField(3)
  final Role role;

  const AppUser({
    required this.id,
    required this.login,
    required this.displayName,
    required this.role,
  });
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 4;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      login: fields[1] as String,
      displayName: fields[2] as String,
      role: fields[3] as Role,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.login)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.role);
  }
}

class RoleAdapter extends TypeAdapter<Role> {
  @override
  final int typeId = 3;

  @override
  Role read(BinaryReader reader) => Role.values[reader.readByte() as int];

  @override
  void write(BinaryWriter writer, Role obj) => writer.writeByte(obj.index);
}

@HiveType(typeId: 5)
class Message {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String senderUserId;
  @HiveField(2)
  final String text;
  @HiveField(3)
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
  });
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 5;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      senderUserId: fields[1] as String,
      text: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderUserId)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.createdAt);
  }
}

@HiveType(typeId: 2)
class ServiceRequest {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String serviceId;
  @HiveField(2)
  final String serviceTitle;
  @HiveField(3)
  final String details;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final RequestStatus status;
  // двусторонняя связь: кто подал заявку
  @HiveField(6)
  final String requesterUserId;
  // модератор, который обрабатывает (может быть пусто)
  @HiveField(7)
  final String? assignedModeratorUserId;
  // сообщения в рамках заявки (переписка пользователь ↔ модератор)
  @HiveField(8)
  final List<Message> messages;

  const ServiceRequest({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.details,
    required this.createdAt,
    required this.status,
    required this.requesterUserId,
    this.assignedModeratorUserId,
    this.messages = const [],
  });

  ServiceRequest copyWith({
    String? details,
    RequestStatus? status,
    String? assignedModeratorUserId,
    List<Message>? messages,
  }) => ServiceRequest(
        id: id,
        serviceId: serviceId,
        serviceTitle: serviceTitle,
        details: details ?? this.details,
        createdAt: createdAt,
        status: status ?? this.status,
        requesterUserId: requesterUserId,
        assignedModeratorUserId: assignedModeratorUserId ?? this.assignedModeratorUserId,
        messages: messages ?? this.messages,
      );
}

class ServiceRequestAdapter extends TypeAdapter<ServiceRequest> {
  @override
  final int typeId = 2;

  @override
  ServiceRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceRequest(
      id: fields[0] as String,
      serviceId: fields[1] as String,
      serviceTitle: fields[2] as String,
      details: fields[3] as String,
      createdAt: fields[4] as DateTime,
      status: fields[5] as RequestStatus,
      requesterUserId: fields[6] as String,
      assignedModeratorUserId: fields[7] as String?,
      messages: (fields[8] as List).cast<Message>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceRequest obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceId)
      ..writeByte(2)
      ..write(obj.serviceTitle)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.requesterUserId)
      ..writeByte(7)
      ..write(obj.assignedModeratorUserId)
      ..writeByte(8)
      ..write(obj.messages);
  }
}

String statusToText(RequestStatus s) {
  switch (s) {
    case RequestStatus.submitted:
      return 'Отправлена';
    case RequestStatus.inReview:
      return 'На рассмотрении';
    case RequestStatus.approved:
      return 'Одобрена';
    case RequestStatus.rejected:
      return 'Отклонена';
  }
}

MaterialColor statusColor(RequestStatus s) {
  switch (s) {
    case RequestStatus.submitted:
      return Colors.blue;
    case RequestStatus.inReview:
      return Colors.amber;
    case RequestStatus.approved:
      return Colors.green;
    case RequestStatus.rejected:
      return Colors.red;
  }
}



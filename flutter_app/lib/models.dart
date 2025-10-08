import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Simple catalog of services offered to employees
@immutable
class Service {
  const Service({
    required this.id, 
    required this.title, 
    required this.description,
    this.subcategories = const [],
  });
  final String id;
  final String title;
  final String description;
  final List<Service> subcategories;
}

// Predefined demo services (can be replaced by API later)
const List<Service> kDemoServices = [
  // 1. Кадровые документы и справки
  Service(
    id: 'hr_documents',
    title: 'Кадровые документы',
    description: 'Справки, копии документов, трудовая книжка',
    subcategories: [
      Service(
        id: 'hr_doc_2ndfl',
        title: 'Справка 2-НДФЛ',
        description: 'Запрос справки о доходах для налоговой',
      ),
      Service(
        id: 'hr_doc_work_confirm',
        title: 'Справка с места работы',
        description: 'Подтверждение трудоустройства для банка, визы и т.д.',
      ),
      Service(
        id: 'hr_doc_work_book',
        title: 'Выписка из трудовой книжки',
        description: 'Копия или выписка из трудовой книжки',
      ),
      Service(
        id: 'hr_doc_salary',
        title: 'Справка о заработной плате',
        description: 'Справка о размере зарплаты за период',
      ),
      Service(
        id: 'hr_doc_experience',
        title: 'Справка о стаже',
        description: 'Подтверждение трудового стажа на предприятии',
      ),
    ],
  ),
  
  // 2. Отпуска
  Service(
    id: 'vacation',
    title: 'Отпуска',
    description: 'Оформление всех видов отпусков',
    subcategories: [
      Service(
        id: 'vacation_regular',
        title: 'Ежегодный оплачиваемый отпуск',
        description: 'Основной отпуск согласно трудовому договору',
      ),
      Service(
        id: 'vacation_unpaid',
        title: 'Отпуск без сохранения зарплаты',
        description: 'Неоплачиваемый отпуск по личным обстоятельствам',
      ),
      Service(
        id: 'vacation_study',
        title: 'Учебный отпуск',
        description: 'Отпуск для сдачи экзаменов или защиты диплома',
      ),
      Service(
        id: 'vacation_additional',
        title: 'Дополнительный отпуск',
        description: 'Дополнительные дни отпуска за вредные условия труда',
      ),
    ],
  ),
  
  // 3. Больничные и медицина
  Service(
    id: 'medical',
    title: 'Больничные и медицина',
    description: 'Оформление больничных листов и медицинских услуг',
    subcategories: [
      Service(
        id: 'medical_sick_leave',
        title: 'Больничный лист',
        description: 'Оформление и оплата больничного листа',
      ),
      Service(
        id: 'medical_child_care',
        title: 'Больничный по уходу за ребенком',
        description: 'Оформление больничного по уходу за больным ребенком',
      ),
      Service(
        id: 'medical_injury',
        title: 'Производственная травма',
        description: 'Оформление больничного при производственной травме',
      ),
      Service(
        id: 'medical_checkup',
        title: 'Медосмотр',
        description: 'Запись на обязательный медицинский осмотр',
      ),
      Service(
        id: 'medical_dms',
        title: 'ДМС (добровольное медстрахование)',
        description: 'Оформление полиса ДМС для сотрудника',
      ),
    ],
  ),
  
  // 4. Социальные льготы и выплаты
  Service(
    id: 'social_benefits',
    title: 'Социальные льготы',
    description: 'Материальная помощь, компенсации, льготы',
    subcategories: [
      Service(
        id: 'social_maternity',
        title: 'Материальная помощь при рождении',
        description: 'Единовременная выплата при рождении ребенка',
      ),
      Service(
        id: 'social_child_payments',
        title: 'Детские пособия',
        description: 'Ежемесячные выплаты на детей сотрудников',
      ),
      Service(
        id: 'social_kindergarten',
        title: 'Компенсация за детский сад',
        description: 'Частичная компенсация расходов на детский сад',
      ),
      Service(
        id: 'social_financial_aid',
        title: 'Материальная помощь',
        description: 'Единовременная материальная помощь в трудной ситуации',
      ),
      Service(
        id: 'social_funeral',
        title: 'Похоронное пособие',
        description: 'Материальная помощь на погребение',
      ),
      Service(
        id: 'social_gifts',
        title: 'Подарки детям сотрудников',
        description: 'Новогодние подарки и праздничные мероприятия',
      ),
    ],
  ),
  
  // 5. Обучение и развитие
  Service(
    id: 'training',
    title: 'Обучение и развитие',
    description: 'Курсы, тренинги, повышение квалификации',
    subcategories: [
      Service(
        id: 'training_courses',
        title: 'Профессиональные курсы',
        description: 'Запрос на обучение за счет предприятия',
      ),
      Service(
        id: 'training_certification',
        title: 'Сертификация',
        description: 'Прохождение профессиональной сертификации',
      ),
      Service(
        id: 'training_conference',
        title: 'Участие в конференции',
        description: 'Командировка на профессиональную конференцию',
      ),
      Service(
        id: 'training_education',
        title: 'Высшее образование',
        description: 'Компенсация расходов на обучение в ВУЗе',
      ),
    ],
  ),
  
  // 6. Рабочее место и условия труда
  Service(
    id: 'workplace',
    title: 'Рабочее место',
    description: 'Оборудование, условия труда, график работы',
    subcategories: [
      Service(
        id: 'workplace_equipment',
        title: 'Заказ оборудования',
        description: 'Запрос на выдачу рабочего оборудования',
      ),
      Service(
        id: 'workplace_repair',
        title: 'Ремонт оборудования',
        description: 'Заявка на ремонт неисправного оборудования',
      ),
      Service(
        id: 'workplace_schedule',
        title: 'Изменение графика работы',
        description: 'Запрос на изменение рабочего графика',
      ),
      Service(
        id: 'workplace_remote',
        title: 'Удаленная работа',
        description: 'Оформление удаленного формата работы',
      ),
      Service(
        id: 'workplace_parking',
        title: 'Парковочное место',
        description: 'Запрос на выделение парковочного места',
      ),
    ],
  ),
  
  // 7. Пенсия и увольнение
  Service(
    id: 'retirement',
    title: 'Пенсия и увольнение',
    description: 'Оформление пенсии, увольнение, расчет',
    subcategories: [
      Service(
        id: 'retirement_pension',
        title: 'Оформление пенсии',
        description: 'Подготовка документов для выхода на пенсию',
      ),
      Service(
        id: 'retirement_resignation',
        title: 'Увольнение по собственному желанию',
        description: 'Оформление увольнения и расчета',
      ),
      Service(
        id: 'retirement_agreement',
        title: 'Увольнение по соглашению сторон',
        description: 'Расторжение трудового договора по соглашению',
      ),
    ],
  ),
  
  // 8. Прочие обращения
  Service(
    id: 'other',
    title: 'Другие вопросы',
    description: 'Прочие обращения в отдел кадров',
    subcategories: [
      Service(
        id: 'other_complaint',
        title: 'Жалоба или предложение',
        description: 'Обращение с жалобой или предложением по улучшению',
      ),
      Service(
        id: 'other_transfer',
        title: 'Перевод на другую должность',
        description: 'Запрос на перевод внутри предприятия',
      ),
      Service(
        id: 'other_personal_data',
        title: 'Изменение персональных данных',
        description: 'Обновление личной информации в кадровых документах',
      ),
      Service(
        id: 'other_question',
        title: 'Общий вопрос',
        description: 'Консультация по кадровым вопросам',
      ),
    ],
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

class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 1;

  @override
  RequestStatus read(BinaryReader reader) => RequestStatus.values[reader.readByte() as int];

  @override
  void write(BinaryWriter writer, RequestStatus obj) => writer.writeByte(obj.index);
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
  @HiveField(4)
  final String password; // demo only
  @HiveField(5)
  final String? avatarUrl; // URL аватарки
  @HiveField(6)
  final String? position; // должность

  const AppUser({
    required this.id,
    required this.login,
    required this.displayName,
    required this.role,
    required this.password,
    this.avatarUrl,
    this.position,
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
      password: fields[4] as String,
      avatarUrl: fields[5] as String?,
      position: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.login)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.avatarUrl)
      ..writeByte(6)
      ..write(obj.position);
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

@HiveType(typeId: 6)
class SupportTicket {
  @HiveField(0)
  final String id; // uuid
  @HiveField(1)
  final String userId; // кто создал тикет
  @HiveField(2)
  final String userName; // имя пользователя
  @HiveField(3)
  final String subject; // тема обращения
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final List<Message> messages;
  @HiveField(6)
  final bool isResolved; // решён ли запрос

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.createdAt,
    this.messages = const [],
    this.isResolved = false,
  });

  SupportTicket copyWith({
    List<Message>? messages,
    bool? isResolved,
  }) => SupportTicket(
        id: id,
        userId: userId,
        userName: userName,
        subject: subject,
        createdAt: createdAt,
        messages: messages ?? this.messages,
        isResolved: isResolved ?? this.isResolved,
      );
}

class SupportTicketAdapter extends TypeAdapter<SupportTicket> {
  @override
  final int typeId = 6;

  @override
  SupportTicket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportTicket(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      subject: fields[3] as String,
      createdAt: fields[4] as DateTime,
      messages: (fields[5] as List).cast<Message>(),
      isResolved: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SupportTicket obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.messages)
      ..writeByte(6)
      ..write(obj.isResolved);
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



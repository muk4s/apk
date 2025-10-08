import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models.dart';

const String requestsBoxName = 'requestsBox';

// Корневая страница заявок с вкладками
class RequestsRootPage extends StatelessWidget {
  const RequestsRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Заявки'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Каталог'),
            Tab(text: 'Мои'),
            Tab(text: 'Очередь'),
          ]),
        ),
        body: const TabBarView(children: [
          ServicesCatalog(),
          MyRequestsPage(),
          ModeratorQueuePage(),
        ]),
      ),
    );
  }
}

// Каталог услуг
class ServicesCatalog extends StatelessWidget {
  const ServicesCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: kDemoServices.length,
      itemBuilder: (context, index) {
        final s = kDemoServices[index];
        return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (s.subcategories.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SubcategoriesPage(service: s)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewRequestPage(service: s)),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getServiceIcon(s.id),
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  IconData _getServiceIcon(String serviceId) {
    switch (serviceId) {
      case 'hr_documents':
        return Icons.description_outlined;
      case 'vacation':
        return Icons.beach_access_outlined;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'social_benefits':
        return Icons.volunteer_activism_outlined;
      case 'training':
        return Icons.school_outlined;
      case 'workplace':
        return Icons.business_center_outlined;
      case 'retirement':
        return Icons.elderly_outlined;
      case 'other':
        return Icons.help_outline;
      default:
        return Icons.description_outlined;
    }
  }
}

// Страница подкатегорий
class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({super.key, required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: service.subcategories.length,
        itemBuilder: (context, index) {
          final sub = service.subcategories[index];
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewRequestPage(service: sub)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sub.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
          );
        },
      ),
    );
  }
}

// Очередь модератора
class ModeratorQueuePage extends StatelessWidget {
  const ModeratorQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<ServiceRequest>(requestsBoxName),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final box = Hive.box<ServiceRequest>(requestsBoxName);
        final users = Hive.box<AppUser>('usersBox');
        final me = users.get('current');
        final isModerator = me?.role == Role.moderator || me?.role == Role.adminSuper;
        if (!isModerator) {
          return const Center(child: Text('Доступ только для модератора/админа'));
        }
        return ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<ServiceRequest> b, _) {
            final entries = b.keys.map((k) => MapEntry(k, b.get(k)!)).toList();
            if (entries.isEmpty) return const Center(child: Text('Заявок пока нет'));
            return ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final key = entries[index].key as int;
                final req = entries[index].value;
                final assigned = req.assignedModeratorUserId == me!.id;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(req.serviceTitle),
                    subtitle: Text('${statusToText(req.status)} • От: ${req.requesterUserId} • Сообщений: ${req.messages.length}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!assigned && req.status == RequestStatus.submitted)
                          TextButton(
                            onPressed: () async {
                              await b.put(key, req.copyWith(assignedModeratorUserId: me.id, status: RequestStatus.inReview));
                            },
                            child: const Text('Назначить')
                          ),
                        const SizedBox(width: 4),
                        if (req.status != RequestStatus.approved)
                          IconButton(
                            tooltip: 'Одобрить',
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              await b.put(key, req.copyWith(status: RequestStatus.approved, assignedModeratorUserId: me.id));
                            },
                          ),
                        if (req.status != RequestStatus.rejected)
                          IconButton(
                            tooltip: 'Отклонить',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await b.put(key, req.copyWith(status: RequestStatus.rejected, assignedModeratorUserId: me.id));
                            },
                          ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RequestDetailsPage(requestKey: key)),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Страница создания новой заявки
class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key, required this.service});
  final Service service;

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новая заявка: ${widget.service.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _details,
                decoration: const InputDecoration(
                  labelText: 'Описание запроса',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Заполните описание' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final box = await Hive.openBox<ServiceRequest>(requestsBoxName);
                  final current = Hive.box<AppUser>('usersBox').get('current');
                  if (current == null || current.id == 'guest') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Войдите в аккаунт, чтобы отправлять заявки')));
                    return;
                  }
                  final req = ServiceRequest(
                    id: UniqueKey().toString(),
                    serviceId: widget.service.id,
                    serviceTitle: widget.service.title,
                    details: _details.text.trim(),
                    createdAt: DateTime.now(),
                    status: RequestStatus.submitted,
                    requesterUserId: current.id,
                    assignedModeratorUserId: null,
                    messages: const [],
                  );
                  await box.add(req);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заявка отправлена')),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Отправить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Мои заявки
class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заявки')),
      body: FutureBuilder(
        future: Hive.openBox<ServiceRequest>(requestsBoxName),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final box = Hive.box<ServiceRequest>(requestsBoxName);
          return ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<ServiceRequest> b, _) {
              final keys = b.keys.toList();
              if (keys.isEmpty) {
                return const Center(child: Text('Пока нет заявок'));
              }
              return ListView.separated(
                itemCount: keys.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final key = keys[index];
                  final req = b.get(key)!;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(req.serviceTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(req.details),
                      trailing: Chip(
                        label: Text(statusToText(req.status)),
                        backgroundColor: statusColor(req.status).shade100,
                      ),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RequestDetailsPage(requestKey: key as int)),
                        );
                      },
                      onLongPress: () async {
                        final next = {
                          RequestStatus.submitted: RequestStatus.inReview,
                          RequestStatus.inReview: RequestStatus.approved,
                          RequestStatus.approved: RequestStatus.approved,
                          RequestStatus.rejected: RequestStatus.rejected,
                        }[req.status]!;
                        await b.put(key, req.copyWith(status: next));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Детали заявки
class RequestDetailsPage extends StatefulWidget {
  const RequestDetailsPage({super.key, required this.requestKey});
  final int requestKey;

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  final TextEditingController _msg = TextEditingController();

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ServiceRequest>(requestsBoxName);
    final req = box.get(widget.requestKey)!;
    final usersBox = Hive.isBoxOpen('usersBox') ? Hive.box<AppUser>('usersBox') : null;
    final currentUser = usersBox?.get('current');

    return Scaffold(
      appBar: AppBar(title: Text('Заявка: ${req.serviceTitle}')),
      body: Column(
        children: [
          ListTile(
            title: Text(statusToText(req.status)),
            subtitle: Text('Заявитель: ${req.requesterUserId}'),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: req.messages.length,
              itemBuilder: (context, index) {
                final m = req.messages[index];
                final isMe = m.senderUserId == (currentUser?.id ?? 'guest');
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.indigo.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msg,
                      decoration: const InputDecoration(
                        hintText: 'Сообщение...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _msg.text.trim();
                      if (text.isEmpty) return;
                      final updated = req.copyWith(
                        messages: [
                          ...req.messages,
                          Message(
                            id: UniqueKey().toString(),
                            senderUserId: currentUser?.id ?? 'guest',
                            text: text,
                            createdAt: DateTime.now(),
                          ),
                        ],
                      );
                      await box.put(widget.requestKey, updated);
                      setState(() {});
                      _msg.clear();
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

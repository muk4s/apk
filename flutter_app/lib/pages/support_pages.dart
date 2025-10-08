import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models.dart';

// Главная страница поддержки (роутер)
class SupportChatPage extends StatelessWidget {
  const SupportChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersBox = Hive.box<AppUser>('usersBox');
    final current = usersBox.get('current');
    final isSupport = current?.role == Role.support;
    
    if (isSupport) {
      return const SupportTicketsListPage();
    } else {
      return const UserSupportPage();
    }
  }
}

// Страница для пользователей - создание и просмотр своих тикетов
class UserSupportPage extends StatelessWidget {
  const UserSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<SupportTicket>('supportTickets'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final box = Hive.box<SupportTicket>('supportTickets');
        final usersBox = Hive.box<AppUser>('usersBox');
        final current = usersBox.get('current');
        final userId = current?.id ?? 'guest';
        
        return Scaffold(
          appBar: AppBar(title: const Text('Поддержка')),
          body: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<SupportTicket> b, _) {
              final myTickets = b.values.where((t) => t.userId == userId).toList();
              
              if (myTickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support_agent, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('У вас пока нет обращений', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => _showCreateTicketDialog(context, current),
                        icon: const Icon(Icons.add),
                        label: const Text('Создать обращение'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: myTickets.length,
                itemBuilder: (context, index) {
                  final ticket = myTickets[index];
                  final key = b.keys.firstWhere((k) => b.get(k)?.id == ticket.id);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ticket.isResolved ? Colors.green : Colors.orange,
                        child: Icon(
                          ticket.isResolved ? Icons.check : Icons.pending,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(ticket.subject),
                      subtitle: Text('${ticket.messages.length} сообщений'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupportChatDetailPage(ticketKey: key as int),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateTicketDialog(context, current),
            icon: const Icon(Icons.add),
            label: const Text('Новое обращение'),
          ),
        );
      },
    );
  }

  void _showCreateTicketDialog(BuildContext context, AppUser? current) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новое обращение в поддержку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Тема обращения',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Сообщение',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              if (subjectController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                return;
              }
              
              final box = Hive.box<SupportTicket>('supportTickets');
              final ticket = SupportTicket(
                id: UniqueKey().toString(),
                userId: current?.id ?? 'guest',
                userName: current?.displayName ?? 'Гость',
                subject: subjectController.text.trim(),
                createdAt: DateTime.now(),
                messages: [
                  Message(
                    id: UniqueKey().toString(),
                    senderUserId: current?.id ?? 'guest',
                    text: messageController.text.trim(),
                    createdAt: DateTime.now(),
                  ),
                ],
              );
              
              await box.add(ticket);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Обращение создано')),
                );
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}

// Страница для поддержки - список всех тикетов
class SupportTicketsListPage extends StatelessWidget {
  const SupportTicketsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<SupportTicket>('supportTickets'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final box = Hive.box<SupportTicket>('supportTickets');
        
        return Scaffold(
          appBar: AppBar(title: const Text('Запросы в поддержку')),
          body: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<SupportTicket> b, _) {
              final tickets = b.values.toList();
              
              if (tickets.isEmpty) {
                return const Center(child: Text('Нет обращений'));
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final key = b.keys.elementAt(index);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ticket.isResolved ? Colors.green : Colors.orange,
                        child: Icon(
                          ticket.isResolved ? Icons.check : Icons.pending,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(ticket.subject),
                      subtitle: Text('От: ${ticket.userName} • ${ticket.messages.length} сообщений'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupportChatDetailPage(ticketKey: key as int),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Страница детального чата по тикету
class SupportChatDetailPage extends StatefulWidget {
  const SupportChatDetailPage({super.key, required this.ticketKey});
  final int ticketKey;

  @override
  State<SupportChatDetailPage> createState() => _SupportChatDetailPageState();
}

class _SupportChatDetailPageState extends State<SupportChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<SupportTicket>('supportTickets');
    final ticket = box.get(widget.ticketKey)!;
    final usersBox = Hive.box<AppUser>('usersBox');
    final current = usersBox.get('current');
    final isSupport = current?.role == Role.support;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.subject),
        actions: [
          if (isSupport && !ticket.isResolved)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () async {
                await box.put(widget.ticketKey, ticket.copyWith(isResolved: true));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Тикет закрыт')),
                  );
                }
              },
              tooltip: 'Закрыть тикет',
            ),
        ],
      ),
      body: Column(
        children: [
          if (ticket.isResolved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade100,
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Обращение решено', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ticket.messages.length,
              itemBuilder: (context, index) {
                final message = ticket.messages[index];
                final isMe = message.senderUserId == (current?.id ?? 'guest');
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message.text),
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
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;
                      
                      final newMessage = Message(
                        id: UniqueKey().toString(),
                        senderUserId: current?.id ?? 'guest',
                        text: text,
                        createdAt: DateTime.now(),
                      );
                      
                      final updatedTicket = ticket.copyWith(
                        messages: [...ticket.messages, newMessage],
                      );
                      
                      await box.put(widget.ticketKey, updatedTicket);
                      _messageController.clear();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

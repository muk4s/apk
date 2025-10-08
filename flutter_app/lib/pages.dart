import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

const String requestsBoxName = 'requestsBox';

// Вспомогательная функция для получения ImageProvider
ImageProvider? getAvatarImageProvider(String? avatarPath) {
  if (avatarPath == null || avatarPath.isEmpty) return null;
  
  if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
    return NetworkImage(avatarPath);
  } else {
    return FileImage(File(avatarPath));
  }
}

class _TabsData {
  final List<Widget> pages;
  final List<NavigationDestination> destinations;
  
  _TabsData({required this.pages, required this.destinations});
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0; // default to Account

  @override
  Widget build(BuildContext context) {
    final usersBox = Hive.isBoxOpen('usersBox') ? Hive.box<AppUser>('usersBox') : null;
    
    if (usersBox == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return ValueListenableBuilder(
      valueListenable: usersBox.listenable(),
      builder: (context, Box<AppUser> box, _) {
        final current = box.get('current');
        final isAuthorized = current != null && current.id != 'guest';
        final role = current?.role;
        
        final tabsData = _getTabsForRole(role, isAuthorized, current, usersBox);
        
        return Scaffold(
          body: tabsData.pages[_index.clamp(0, tabsData.pages.length - 1)],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index.clamp(0, tabsData.pages.length - 1),
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: tabsData.destinations,
          ),
        );
      },
    );
  }

  _TabsData _getTabsForRole(Role? role, bool isAuthorized, AppUser? current, Box<AppUser> usersBox) {
    if (!isAuthorized || role == null) {
      return _TabsData(
        pages: [AccountPage(current: null, usersBox: usersBox)],
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Аккаунт'),
        ],
      );
    }
    
    switch (role) {
      case Role.support:
        return _TabsData(
          pages: [
            AccountPage(current: current, usersBox: usersBox),
            const SupportChatPage(),
          ],
          destinations: const [
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Аккаунт'),
            NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'Поддержка'),
          ],
        );
      case Role.moderator:
        return _TabsData(
          pages: [
            AccountPage(current: current, usersBox: usersBox),
            const RequestsRootPage(),
            const InfoPage(),
          ],
          destinations: const [
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Аккаунт'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Заявки'),
            NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Инфо'),
          ],
        );
      case Role.adminUserManager:
      case Role.adminSuper:
        return _TabsData(
          pages: [
            AccountPage(current: current, usersBox: usersBox),
            const UsersManagementPage(),
            const RequestsRootPage(),
            const InfoPage(),
          ],
          destinations: const [
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Аккаунт'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Пользователи'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Заявки'),
            NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Инфо'),
          ],
        );
      case Role.user:
      default:
        return _TabsData(
          pages: [
            AccountPage(current: current, usersBox: usersBox),
            const RequestsRootPage(),
            const InfoPage(),
            const SupportChatPage(),
          ],
          destinations: const [
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Аккаунт'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Заявки'),
            NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Инфо'),
            NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'Поддержка'),
          ],
        );
    }
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.current, required this.usersBox});
  final AppUser? current;
  final Box<AppUser>? usersBox;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мой аккаунт')),
      body: current == null ? _buildUnauthorizedView(context) : _buildAuthorizedView(context),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Авторизация',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Войдите в систему, чтобы отправлять заявки',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => const _LoginDialog()),
              icon: const Icon(Icons.login),
              label: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Профиль пользователя с анимацией
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'user_avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: getAvatarImageProvider(current!.avatarUrl),
                            child: current!.avatarUrl == null 
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current!.displayName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (current!.position != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      current!.position!,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Chip(
                              avatar: Icon(
                                Icons.shield_outlined,
                                size: 18,
                                color: _getRoleColor(current!.role),
                              ),
                              label: Text(_getRoleDisplayName(current!.role)),
                              backgroundColor: _getRoleColor(current!.role).shade100,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Кнопка редактирования профиля
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать профиль'),
              ),
            ),
            const SizedBox(height: 24),
          
          // Админ панель
          if (current!.role == Role.adminUserManager || current!.role == Role.adminSuper) ...[
            Text('Админ панель', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
                    final u = AppUser(
                      id: id, 
                      login: 'user$id', 
                      displayName: 'Пользователь $id', 
                      role: Role.user, 
                      password: 'user$id',
                      avatarUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 10}',
                      position: 'Новый сотрудник'
                    );
                    await usersBox!.put(id, u);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Создан новый пользователь')));
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Создать пользователя'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // сбросить текущего пользователя на демо-юзера
                    await usersBox!.put('current', usersBox!.get('u_user')!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Текущий пользователь сброшен')));
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Сброс текущего'),
                ),
              ],
            ),
            const Divider(height: 32),
          ],
          
          // Информация о тестовых аккаунтах - только для админа учёток
          if (current!.role == Role.adminUserManager) ...[
            Text('Предзаданные аккаунты для тестирования:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('• admin / admin123 (Супер-админ)'),
            const Text('• admin-accounts / adminacc123 (Админ учёток)'),
            const Text('• moderator / moderator123 (Модератор)'),
            const Text('• support / support123 (Поддержка)'),
            const Text('• user / user123 (Пользователь)'),
            const SizedBox(height: 24),
          ],
          
          // Кнопка выхода
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    if (usersBox != null) {
      await usersBox!.put('current', const AppUser(
        id: 'guest',
        login: 'guest',
        displayName: 'Гость',
        role: Role.user,
        password: '',
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы вышли из системы')),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditProfileDialog(current: current!, usersBox: usersBox!),
    );
  }

  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.user:
        return 'Пользователь';
      case Role.moderator:
        return 'Модератор';
      case Role.adminUserManager:
        return 'Админ учёток';
      case Role.adminSuper:
        return 'Супер-админ';
      case Role.support:
        return 'Поддержка';
    }
  }

  MaterialColor _getRoleColor(Role role) {
    switch (role) {
      case Role.user:
        return Colors.blue;
      case Role.moderator:
        return Colors.orange;
      case Role.adminUserManager:
        return Colors.purple;
      case Role.adminSuper:
        return Colors.red;
      case Role.support:
        return Colors.green;
    }
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({super.key, required this.current, required this.usersBox});
  final AppUser current;
  final Box<AppUser> usersBox;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _displayName;
  late final TextEditingController _position;
  final _form = GlobalKey<FormState>();
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.current.displayName);
    _position = TextEditingController(text: widget.current.position ?? '');
    _avatarPath = widget.current.avatarUrl;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Копируем изображение в постоянное хранилище приложения
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${widget.current.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';
        
        // Копируем файл
        await File(image.path).copy(newPath);
        
        setState(() {
          _avatarPath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе изображения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать профиль'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Предпросмотр аватарки с кнопкой выбора
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarPath != null
                        ? (_avatarPath!.startsWith('http')
                            ? NetworkImage(_avatarPath!)
                            : FileImage(File(_avatarPath!)) as ImageProvider)
                        : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                        tooltip: 'Выбрать из галереи',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _position,
                decoration: const InputDecoration(
                  labelText: 'Должность',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            
            // Создаем обновленного пользователя
            final updatedUser = AppUser(
              id: widget.current.id,
              login: widget.current.login,
              displayName: _displayName.text.trim(),
              role: widget.current.role,
              password: widget.current.password,
              avatarUrl: _avatarPath,
              position: _position.text.trim().isEmpty ? null : _position.text.trim(),
            );
            
            // Обновляем в базе
            await widget.usersBox.put(widget.current.id, updatedUser);
            await widget.usersBox.put('current', updatedUser);
            
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Профиль обновлен')),
              );
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _LoginDialog extends StatefulWidget {
  const _LoginDialog({super.key});

  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _login = TextEditingController();
  final _pass = TextEditingController();
  final _form = GlobalKey<FormState>();
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = Hive.box<AppUser>('usersBox');
    return AlertDialog(
      title: const Text('Вход'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _login, decoration: const InputDecoration(labelText: 'Логин')), 
            const SizedBox(height: 8),
            TextFormField(controller: _pass, decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red)))
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            final u = users.values.firstWhere(
              (u) => u.login == _login.text.trim() && u.password == _pass.text,
              orElse: () => const AppUser(id: 'invalid', login: 'invalid', displayName: 'Invalid', role: Role.user, password: 'invalid'),
            );
            if (u.login != _login.text.trim() || u.password != _pass.text) {
              setState(() => _error = 'Неверные логин или пароль');
              return;
            }
            users.put('current', u);
            Navigator.pop(context);
            // Обновляем состояние родительского виджета
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Добро пожаловать, ${u.displayName}!')),
              );
            }
          },
          child: const Text('Войти'),
        )
      ],
    );
  }
}

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

class ServicesCatalog extends StatelessWidget {
  const ServicesCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: kDemoServices.length,
      itemBuilder: (context, index) {
        final s = kDemoServices[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewRequestPage(service: s)),
                );
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
          ),
        );
      },
    );
  }

  IconData _getServiceIcon(String serviceId) {
    switch (serviceId) {
      case 'sick_leave':
        return Icons.medical_services_outlined;
      case 'vacation':
        return Icons.beach_access_outlined;
      case 'child_support':
        return Icons.family_restroom_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

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

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersBox = Hive.box<AppUser>('usersBox');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление пользователями'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUserDialog(context, usersBox),
            tooltip: 'Добавить пользователя',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: usersBox.listenable(),
        builder: (context, Box<AppUser> box, _) {
          final users = box.values.where((u) => u.id != 'guest' && u.id != 'current').toList();
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: getAvatarImageProvider(user.avatarUrl),
                    child: user.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text('${user.position ?? 'Без должности'} • ${_getRoleText(user.role)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditUserDialog(context, usersBox, user),
                        tooltip: 'Редактировать',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(context, usersBox, user),
                        tooltip: 'Удалить',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getRoleText(Role role) {
    switch (role) {
      case Role.user: return 'Пользователь';
      case Role.moderator: return 'Модератор';
      case Role.adminUserManager: return 'Админ учёток';
      case Role.adminSuper: return 'Супер-админ';
      case Role.support: return 'Поддержка';
    }
  }

  void _showAddUserDialog(BuildContext context, Box<AppUser> usersBox) {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления пользователя в разработке')),
    );
  }

  void _showEditUserDialog(BuildContext context, Box<AppUser> usersBox, AppUser user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция редактирования пользователя в разработке')),
    );
  }

  void _deleteUser(BuildContext context, Box<AppUser> usersBox, AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text('Вы уверены, что хотите удалить ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await usersBox.delete(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.displayName} удален')),
        );
      }
    }
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Информация по заявкам')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Статусы заявок'),
            subtitle: Text('Отправлена → На рассмотрении → Одобрена/Отклонена'),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Конфиденциальность'),
            subtitle: Text('Ваши данные хранятся локально (MVP). В проде — на сервере.'),
          ),
        ],
      ),
    );
  }
}

class SupportChatPage extends StatelessWidget {
  const SupportChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupportChatView();
  }
}

class _SupportChatView extends StatefulWidget {
  const _SupportChatView();

  @override
  State<_SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<_SupportChatView> {
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<Message>('supportChat'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final box = Hive.box<Message>('supportChat');
        final usersBox = Hive.box<AppUser>('usersBox');
        final current = usersBox.get('current');
        final isSupport = current?.role == Role.support;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Чат с поддержкой'),
            actions: [
              if (isSupport)
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportRequestsPage()),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<Message> b, _) {
                    final keys = b.keys.toList();
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final m = b.get(keys[index])!;
                        final isMe = m.senderUserId == (current?.id ?? 'guest');
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
                          controller: _c,
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
                          final text = _c.text.trim();
                          if (text.isEmpty) return;
                          await box.add(Message(
                            id: UniqueKey().toString(),
                            senderUserId: current?.id ?? 'guest',
                            text: text,
                            createdAt: DateTime.now(),
                          ));
                          _c.clear();
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class SupportRequestsPage extends StatelessWidget {
  const SupportRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Запросы пользователей')),
      body: FutureBuilder(
        future: Hive.openBox<ServiceRequest>(requestsBoxName),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final box = Hive.box<ServiceRequest>(requestsBoxName);
          final users = Hive.box<AppUser>('usersBox');
          final me = users.get('current');
          final isSupport = me?.role == Role.support;
          if (!isSupport) {
            return const Center(child: Text('Доступ только для поддержки'));
          }
          return ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<ServiceRequest> b, _) {
              final entries = b.keys.map((k) => MapEntry(k, b.get(k)!)).toList();
              if (entries.isEmpty) return const Center(child: Text('Запросов пока нет'));
              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final key = entries[index].key as int;
                  final req = entries[index].value;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(req.serviceTitle),
                      subtitle: Text('${statusToText(req.status)} • От: ${req.requesterUserId} • Сообщений: ${req.messages.length}'),
                      trailing: const Icon(Icons.chevron_right),
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
      ),
    );
  }
}

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
                    // для MVP берём текущего пользователя из отдельного бокса (или guest)
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

class RequestDetailsPage extends StatefulWidget {
  const RequestDetailsPage({super.key, required this.requestKey});
  final int requestKey; // Hive key

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



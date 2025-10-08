import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models.dart';

// Вспомогательная функция для получения ImageProvider
ImageProvider? getAvatarImageProvider(String? avatarPath) {
  if (avatarPath == null || avatarPath.isEmpty) return null;
  
  if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
    return NetworkImage(avatarPath);
  } else {
    return FileImage(File(avatarPath));
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
            onPressed: () => showDialog(context: context, builder: (_) => const LoginDialog()),
            icon: const Icon(Icons.login),
            label: const Text('Войти'),
          ),
        ],
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
          // Профиль пользователя
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
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
                  onPressed: () => _showCreateUserDialog(context),
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
      builder: (_) => EditProfileDialog(current: current!, usersBox: usersBox!),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateUserDialog(usersBox: usersBox!),
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

// Диалог редактирования профиля
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.current, required this.usersBox});
  final AppUser current;
  final Box<AppUser> usersBox;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
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
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${widget.current.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';
        await File(image.path).copy(newPath);
        setState(() => _avatarPath = newPath);
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
            
            final updatedUser = AppUser(
              id: widget.current.id,
              login: widget.current.login,
              displayName: _displayName.text.trim(),
              role: widget.current.role,
              password: widget.current.password,
              avatarUrl: _avatarPath,
              position: _position.text.trim().isEmpty ? null : _position.text.trim(),
            );
            
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

// Диалог создания пользователя
class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key, required this.usersBox});
  final Box<AppUser> usersBox;

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _displayNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Role _selectedRole = Role.user;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _displayNameController.dispose();
    _positionController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
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
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_new_user_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';
        await File(image.path).copy(newPath);
        setState(() => _avatarPath = newPath);
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
      title: const Text('Создать пользователя'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                    child: _avatarPath == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                        tooltip: 'Выбрать фото',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Должность',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите должность' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Введите логин';
                  final exists = widget.usersBox.values.any((u) => u.login == v.trim());
                  if (exists) return 'Логин уже существует';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? 'Минимум 4 символа' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Role>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Роль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield),
                ),
                items: Role.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleText(role)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
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
            
            final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
            final newUser = AppUser(
              id: id,
              login: _loginController.text.trim(),
              displayName: _displayNameController.text.trim(),
              role: _selectedRole,
              password: _passwordController.text,
              avatarUrl: _avatarPath,
              position: _positionController.text.trim(),
            );
            
            await widget.usersBox.put(id, newUser);
            
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Пользователь ${newUser.displayName} создан')),
              );
            }
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }

  String _getRoleText(Role role) {
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
}

// Диалог входа
class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register Hive adapters for typed models
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RequestStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ServiceRequestAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(RoleAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(AppUserAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(MessageAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(SupportTicketAdapter());
  }
  if (!Hive.isBoxOpen('usersBox')) {
    final users = await Hive.openBox<AppUser>('usersBox');
    // seed demo users only if they don't exist
    if (!users.containsKey('u_user')) {
      users.put('u_user', const AppUser(
        id: 'u_user', 
        login: 'user', 
        displayName: 'Иван Пользователь', 
        role: Role.user, 
        password: 'user123',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        position: 'Специалист по продажам'
      ));
    }
    if (!users.containsKey('u_mod')) {
      users.put('u_mod', const AppUser(
        id: 'u_mod', 
        login: 'moderator', 
        displayName: 'Мария Модератор', 
        role: Role.moderator, 
        password: 'moderator123',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        position: 'Модератор заявок'
      ));
    }
    if (!users.containsKey('u_admin_um')) {
      users.put('u_admin_um', const AppUser(
        id: 'u_admin_um', 
        login: 'admin-accounts', 
        displayName: 'Админ (учётки)', 
        role: Role.adminUserManager, 
        password: 'adminacc123',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        position: 'Администратор учётных записей'
      ));
    }
    if (!users.containsKey('u_admin')) {
      users.put('u_admin', const AppUser(
        id: 'u_admin', 
        login: 'admin', 
        displayName: 'Супер‑админ', 
        role: Role.adminSuper, 
        password: 'admin123',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        position: 'Системный администратор'
      ));
    }
    if (!users.containsKey('u_support')) {
      users.put('u_support', const AppUser(
        id: 'u_support', 
        login: 'support', 
        displayName: 'Служба поддержки', 
        role: Role.support, 
        password: 'support123',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        position: 'Специалист поддержки'
      ));
    }
    if (!users.containsKey('current')) {
      users.put('current', const AppUser(
        id: 'guest',
        login: 'guest',
        displayName: 'Гость',
        role: Role.user,
        password: '',
      ));
    }
  }
  runApp(const EmployeeServicesApp());
}

class EmployeeServicesApp extends StatelessWidget {
  const EmployeeServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Services',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        cardTheme: CardThemeData(
          margin: const EdgeInsets.all(8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
      home: const ShellPage(),
    );
  }
}



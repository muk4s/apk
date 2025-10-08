import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'pages/account_page.dart';
import 'pages/requests_pages.dart';
import 'pages/support_pages.dart';
import 'pages/admin_pages.dart';

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
      // Неавторизованный пользователь видит те же вкладки, что и обычный пользователь
      return _TabsData(
        pages: [
          AccountPage(current: null, usersBox: usersBox),
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
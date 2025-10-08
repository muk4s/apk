import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models.dart';
import 'account_page.dart';

// Страница управления пользователями
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления пользователя в разработке')),
    );
  }

  void _showEditUserDialog(BuildContext context, Box<AppUser> usersBox, AppUser user) {
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

// Страница информации
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Информация о категориях заявок')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryInfo(
            context,
            icon: Icons.description_outlined,
            color: Colors.blue,
            title: '📋 Кадровые документы',
            description: 'Получение справок и документов, связанных с трудовой деятельностью. '
                'Все справки оформляются в электронном виде и могут быть получены в течение 1-3 рабочих дней. '
                'Справки 2-НДФЛ, о стаже, о заработной плате необходимы для банков, налоговой, визовых центров.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.beach_access_outlined,
            color: Colors.orange,
            title: '🏖️ Отпуска',
            description: 'Оформление всех видов отпусков согласно Трудовому кодексу РФ. '
                'Ежегодный оплачиваемый отпуск предоставляется продолжительностью 28 календарных дней. '
                'Заявку на отпуск необходимо подавать не менее чем за 14 дней до начала отпуска. '
                'Также доступны учебные отпуска и отпуска без сохранения заработной платы.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.medical_services_outlined,
            color: Colors.red,
            title: '🏥 Больничные и медицина',
            description: 'Оформление больничных листов и медицинских услуг для сотрудников. '
                'Больничный лист необходимо предоставить в течение 6 месяцев после выздоровления. '
                'Предприятие организует обязательные медосмотры для определенных категорий работников. '
                'Доступно оформление полиса ДМС с расширенным покрытием медицинских услуг.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.volunteer_activism_outlined,
            color: Colors.green,
            title: '🤝 Социальные льготы',
            description: 'Материальная поддержка сотрудников в различных жизненных ситуациях. '
                'При рождении ребенка предоставляется единовременная материальная помощь. '
                'Действуют программы поддержки семей с детьми: компенсация расходов на детский сад, '
                'новогодние подарки детям сотрудников. В трудных жизненных ситуациях можно обратиться '
                'за дополнительной материальной помощью.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.school_outlined,
            color: Colors.purple,
            title: '🎓 Обучение и развитие',
            description: 'Программы профессионального развития и повышения квалификации сотрудников. '
                'Предприятие оплачивает обучение на профессиональных курсах, тренингах и конференциях, '
                'связанных с вашей должностью. Возможна частичная компенсация расходов на получение '
                'высшего образования по профильной специальности. Сертификация специалистов проводится '
                'за счет предприятия.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.business_center_outlined,
            color: Colors.indigo,
            title: '💼 Рабочее место',
            description: 'Обеспечение комфортных условий труда и необходимого оборудования. '
                'Вы можете запросить выдачу рабочего оборудования: ноутбук, монитор, клавиатуру, мышь. '
                'При неисправности техники подается заявка на ремонт или замену. Возможно оформление '
                'удаленного формата работы по согласованию с руководителем. Для сотрудников доступны '
                'парковочные места на территории предприятия.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.elderly_outlined,
            color: Colors.brown,
            title: '👴 Пенсия и увольнение',
            description: 'Оформление документов при выходе на пенсию или увольнении. '
                'Отдел кадров поможет подготовить все необходимые документы для Пенсионного фонда. '
                'При увольнении по собственному желанию необходимо уведомить работодателя за 2 недели. '
                'Расчет производится в день увольнения. Возможно увольнение по соглашению сторон '
                'с выплатой компенсации.',
          ),
          const SizedBox(height: 16),
          _buildCategoryInfo(
            context,
            icon: Icons.help_outline,
            color: Colors.grey,
            title: '❓ Другие вопросы',
            description: 'Прочие обращения в отдел кадров и социальную службу предприятия. '
                'Вы можете подать жалобу или предложение по улучшению работы предприятия. '
                'Доступен перевод на другую должность внутри компании. При изменении персональных '
                'данных (смена фамилии, адреса, паспорта) необходимо обновить информацию в кадровых документах. '
                'По любым вопросам можно получить консультацию специалиста отдела кадров.',
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Важно знать',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Все заявки обрабатываются в порядке очереди. '
                    'Вы можете отслеживать статус своей заявки в разделе "Мои заявки". '
                    'При возникновении вопросов обращайтесь в службу поддержки.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

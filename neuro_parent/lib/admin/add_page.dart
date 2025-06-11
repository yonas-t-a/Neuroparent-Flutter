import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenPadding = MediaQuery.of(context).size.width * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenPadding,
            vertical: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTipCard(
                  context,
                  title: 'Tips and Tricks',
                  subtitle: 'Add tips and tricks',
                  icon: Icons.sunny,
                  onTap: () {
                    context.go('/admin/create-article');
                  },
                ),
                const SizedBox(height: 12),
                _buildEventItem(
                  context,
                  title: 'Event',
                  subtitle: 'Add Event',
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    context.go('/admin/create-event');
                  },
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Edit',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTipCard(
                  context,
                  title: 'Tips and Tricks',
                  subtitle: 'Edit my tips and tricks',
                  icon: Icons.sunny,
                  onTap: () {
                    context.go('/admin/edit-article');
                  },
                ),
                _buildEventItem(
                  context,
                  title: 'Event',
                  subtitle: 'Edit my Event',
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    context.go('/admin/edit-event');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFFF3F6FC),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF8D1D1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.yellow),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEventItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Color(0xFFE3EBF5), width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE3EBF5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
int _getCurrentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/events')) return 1;
  if (location.startsWith('/registered')) return 2;
  if (location.startsWith('/articles')) return 3;
  if (location.startsWith('/profile')) return 4;
  if (location.startsWith('/admin/add')) return 5;
  return 0;
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MenuCard(
              icon: Icons.qr_code,
              title: 'My QR Code',
              subtitle: 'Show this to teacher for attendance',
              color: Colors.green,
              onTap: () => context.push('/qr'),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.person,
              title: 'My Profile',
              subtitle: 'View and edit your details',
              color: Colors.blue,
              onTap: () => context.push('/profile'),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.history,
              title: 'Attendance History',
              subtitle: 'View your attendance records',
              color: Colors.orange,
              onTap: () => context.push('/history'),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.wifi,
              title: 'Join Class (Online)',
              subtitle: 'Scan teacher QR to join class',
              color: Colors.purple,
              onTap: () => context.push('/join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  static const String routeName = '/attendance/history';

  @override
  Widget build(BuildContext context) {
    final history = [
      {'date': '2024-07-12', 'status': 'Present', 'time': '08:02 - 17:15'},
      {'date': '2024-07-11', 'status': 'Present', 'time': '08:10 - 17:05'},
      {'date': '2024-07-10', 'status': 'Late', 'time': '08:36 - 17:00'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(item['date']!),
                  subtitle: Text(item['time']!),
                  trailing: _StatusChip(status: item['status']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    switch (status.toLowerCase()) {
      case 'late':
        background = const Color(0xFFFFEDD5);
        foreground = const Color(0xFF9A3412);
        break;
      default:
        background = const Color(0xFFDCFCE7);
        foreground = const Color(0xFF166534);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: foreground),
      ),
    );
  }
}

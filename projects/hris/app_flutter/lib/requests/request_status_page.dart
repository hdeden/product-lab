import 'package:flutter/material.dart';

class RequestStatusPage extends StatelessWidget {
  const RequestStatusPage({super.key});

  static const String routeName = '/requests/status';

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Leave request',
        'subtitle': 'Annual leave • 2 days',
        'status': 'Pending',
      },
      {
        'title': 'Overtime',
        'subtitle': '2024-07-12 • 2 hours',
        'status': 'Approved',
      },
      {
        'title': 'Late notice',
        'subtitle': '2024-07-03 • 20 mins',
        'status': 'Rejected',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: items
                    .map(
                      (item) => ListTile(
                        leading: const Icon(Icons.assignment_outlined),
                        title: Text(item['title']!),
                        subtitle: Text(item['subtitle']!),
                        trailing: _StatusChip(status: item['status']!),
                      ),
                    )
                    .toList(),
              ),
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
      case 'approved':
        background = const Color(0xFFDCFCE7);
        foreground = const Color(0xFF166534);
        break;
      case 'rejected':
        background = const Color(0xFFFEE2E2);
        foreground = const Color(0xFF991B1B);
        break;
      default:
        background = const Color(0xFFFFEDD5);
        foreground = const Color(0xFF9A3412);
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

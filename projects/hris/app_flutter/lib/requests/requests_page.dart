import 'package:flutter/material.dart';

import '../ui/hris_theme.dart';
import 'leave_request_page.dart';
import 'late_early_request_page.dart';
import 'overtime_request_page.dart';
import 'request_status_page.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  static const String routeName = '/requests';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: hrisHeaderGradient(),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request center',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit leave, overtime, or late/early notices.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _RequestCard(
            title: 'Leave request',
            subtitle: 'Annual, sick, or other permitted leave types.',
            icon: Icons.beach_access_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(LeaveRequestPage.routeName);
            },
          ),
          _RequestCard(
            title: 'Overtime request',
            subtitle: 'Log overtime hours for approval.',
            icon: Icons.timer_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(OvertimeRequestPage.routeName);
            },
          ),
          _RequestCard(
            title: 'Late/Early notice',
            subtitle: 'Report late arrival or early leave.',
            icon: Icons.schedule_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(LateEarlyRequestPage.routeName);
            },
          ),
          _RequestCard(
            title: 'Request status',
            subtitle: 'Track approvals and history.',
            icon: Icons.fact_check_outlined,
            onTap: () {
              Navigator.of(context).pushNamed(RequestStatusPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hrisGray200,
          child: Icon(icon, color: hrisBlue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

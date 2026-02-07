import 'package:flutter/material.dart';

import '../attendance_page.dart';

class AttendanceClockPage extends StatelessWidget {
  const AttendanceClockPage({super.key});

  static const String routeName = '/attendance/clock';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In/Out'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clock actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use the main attendance screen to capture GPS and submit events.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AttendancePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Open Attendance'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  static const String routeName = '/requests/leave';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
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
                    'Request details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: 'annual', child: Text('Annual')),
                      DropdownMenuItem(value: 'sick', child: Text('Sick')),
                      DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                    ],
                    onChanged: (_) {},
                    decoration: const InputDecoration(
                      labelText: 'Leave type',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End date',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Submit request'),
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

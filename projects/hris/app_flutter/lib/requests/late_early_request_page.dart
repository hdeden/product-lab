import 'package:flutter/material.dart';

class LateEarlyRequestPage extends StatelessWidget {
  const LateEarlyRequestPage({super.key});

  static const String routeName = '/requests/late-early';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Late/Early Notice'),
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
                    'Notice details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: 'late', child: Text('Late')),
                      DropdownMenuItem(value: 'early', child: Text('Early leave')),
                    ],
                    onChanged: (_) {},
                    decoration: const InputDecoration(
                      labelText: 'Type',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expected time',
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
                    child: const Text('Submit notice'),
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

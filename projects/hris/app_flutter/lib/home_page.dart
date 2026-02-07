import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/hris_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, dynamic>> _loadProfile() async {
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    final userId = authUser?.id;
    if (userId == null) {
      throw StateError('No authenticated user.');
    }

    final user = await client
        .from('users')
        .select('id, tenant_id, email')
        .eq('id', userId)
        .maybeSingle();

    final roleRow = await client
        .from('user_roles')
        .select('roles(name)')
        .eq('user_id', userId)
        .maybeSingle();

    return {
      'email': user?['email'] ?? authUser?.email ?? '',
      'tenant_id': user?['tenant_id'] ?? authUser?.userMetadata?['tenant_id'] ?? '',
      'role': roleRow?['roles']?['name'] ??
          authUser?.userMetadata?['role'] ??
          'employee',
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HRIS Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load profile: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? {};

          return ListView(
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
                      'Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'Unknown user',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: 'Tenant',
                          value: data['tenant_id'] ?? '-',
                        ),
                        _InfoChip(
                          label: 'Role',
                          value: data['role'] ?? '-',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/attendance');
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Attendance'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/requests');
                    },
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('Requests'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/payslip');
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Payslip'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: _StatCard(
                      label: 'Clocked in',
                      value: '08:05',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Leave balance',
                      value: '8 days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Next: attendance, leave, and payroll modules.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

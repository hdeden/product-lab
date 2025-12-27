import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'Unknown user',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _ProfileLine(label: 'Tenant ID', value: data['tenant_id'] ?? '-'),
                _ProfileLine(label: 'Role', value: data['role'] ?? '-'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  child: const Text('View profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/attendance');
                  },
                  child: const Text('Attendance'),
                ),
                const SizedBox(height: 12),
                const Text('Next: Attendance, leave, payroll modules.'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

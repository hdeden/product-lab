import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _statusMessage;
  String _tenantId = '';
  String _role = 'employee';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    final userId = authUser?.id;
    if (userId == null) {
      setState(() {
        _statusMessage = 'No authenticated user.';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await client
          .from('users')
          .select('tenant_id')
          .eq('id', userId)
          .maybeSingle();

      final roleRow = await client
          .from('user_roles')
          .select('roles(name)')
          .eq('user_id', userId)
          .maybeSingle();

      final profile = await client
          .from('employee_profiles')
          .select('full_name, phone')
          .eq('user_id', userId)
          .maybeSingle();

      _tenantId = (user?['tenant_id'] ?? authUser?.userMetadata?['tenant_id'] ?? '')
          .toString();
      _role = (roleRow?['roles']?['name'] ??
              authUser?.userMetadata?['role'] ??
              'employee')
          .toString();

      _nameController.text = (profile?['full_name'] ?? '').toString();
      _phoneController.text = (profile?['phone'] ?? '').toString();
    } catch (error) {
      _statusMessage = 'Failed to load profile: $error';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _statusMessage = 'No authenticated user.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      await client.from('employee_profiles').upsert(
        {
          'user_id': userId,
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
        onConflict: 'user_id',
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'Profile saved.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to save profile: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  authUser?.email ?? 'Unknown user',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Tenant ID', value: _tenantId.isEmpty ? '-' : _tenantId),
                _InfoRow(label: 'Role', value: _role),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_statusMessage != null) ...[
                        Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _statusMessage!.startsWith('Failed')
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: Text(_isSaving ? 'Saving...' : 'Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

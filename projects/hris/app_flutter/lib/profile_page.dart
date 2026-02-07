import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/hris_theme.dart';

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
                        authUser?.email ?? 'Unknown user',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: 'Tenant ID',
                        value: _tenantId.isEmpty ? '-' : _tenantId,
                        labelColor: Colors.white70,
                        valueColor: Colors.white,
                      ),
                      _InfoRow(
                        label: 'Role',
                        value: _role,
                        labelColor: Colors.white70,
                        valueColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Personal details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_statusMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _statusMessage!.startsWith('Failed')
                                    ? Theme.of(context)
                                        .colorScheme
                                        .errorContainer
                                    : const Color(0xFFE5EFEA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusMessage!,
                                style: TextStyle(
                                  color: _statusMessage!.startsWith('Failed')
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          FilledButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            child: Text(_isSaving ? 'Saving...' : 'Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: labelColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/hris_theme.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  static const String routeName = '/attendance';

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isSubmitting = false;
  String? _statusMessage;
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<Position?> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _clock(String eventType) async {
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      setState(() {
        _statusMessage = 'No authenticated user.';
      });
      return;
    }

    final tenantId = authUser.userMetadata?['tenant_id'];

    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    try {
      final position = await _getPosition();
      await client.from('attendance_events').insert({
        'tenant_id': tenantId,
        'user_id': authUser.id,
        'event_type': eventType,
        'event_time': DateTime.now().toUtc().toIso8601String(),
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      });

      if (mounted) {
        setState(() {
          final lat = position?.latitude;
          final lng = position?.longitude;
          final location = (lat != null && lng != null)
              ? ' (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})'
              : '';
          _statusMessage = 'Saved $eventType$location.';
          _eventsFuture = _loadEvents();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to save: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadEvents() async {
    final client = Supabase.instance.client;
    return await client
        .from('attendance_events')
        .select('event_type, event_time, latitude, longitude')
        .order('event_time', ascending: false)
        .limit(10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
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
                  'Attendance',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your clock-in/out and location logs.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/attendance/clock');
                      },
                      child: const Text('Clock in/out'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/attendance/history');
                      },
                      child: const Text('View history'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clock status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _isSubmitting ? null : () => _clock('clock_in'),
                          icon: const Icon(Icons.login),
                          label: const Text('Clock In'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _isSubmitting ? null : () => _clock('clock_out'),
                          icon: const Icon(Icons.logout),
                          label: const Text('Clock Out'),
                        ),
                      ),
                    ],
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusMessage!.startsWith('Failed')
                            ? Theme.of(context).colorScheme.errorContainer
                            : hrisGray200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusMessage!.startsWith('Failed')
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent events',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load events: ${snapshot.error}'),
                    );
                  }
                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No events yet.'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final type = event['event_type'] ?? '-';
                      final time = event['event_time']?.toString() ?? '-';
                      final lat = event['latitude'];
                      final lng = event['longitude'];
                      final location = (lat != null && lng != null)
                          ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                          : 'Location unavailable';
                      return ListTile(
                        leading: Icon(
                          type == 'clock_in' ? Icons.login : Icons.logout,
                        ),
                        title: Text(type.replaceAll('_', ' ').toUpperCase()),
                        subtitle: Text('$time • $location'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

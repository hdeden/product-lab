import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _clock('clock_in'),
                    child: const Text('Clock In'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => _clock('clock_out'),
                    child: const Text('Clock Out'),
                  ),
                ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Failed')
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Recent events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load events: ${snapshot.error}'),
                    );
                  }
                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const Center(child: Text('No events yet.'));
                  }
                  return ListView.separated(
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
          ],
        ),
      ),
    );
  }
}

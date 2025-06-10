import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../services/event_service.dart';
import '../../auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class EditEventPage extends ConsumerStatefulWidget {
  const EditEventPage({super.key});

  @override
  ConsumerState<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  late EventRepository eventRepository;
  bool _isDeleting = false;
  int? _deletingEventId;

  Future<List<Event>> _fetchEvents(String? token) async {
    eventRepository = EventRepository(
      eventService: EventService(jwtToken: token),
    );
    return await eventRepository.getEvents();
  }

  Future<void> _deleteEvent(int eventId, String? token) async {
    final repo = EventRepository(eventService: EventService(jwtToken: token));
    setState(() {
      _isDeleting = true;
      _deletingEventId = eventId;
    });
    try {
      await repo.deleteEvent(eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully.')),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete event: \n$e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _deletingEventId = null;
        });
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    int eventId,
    String? token,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Event'),
            content: const Text(
              'Are you sure you want to cancel (delete) this event?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );
    if (result == true) {
      await _deleteEvent(eventId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    String? token;
    if (authState is AuthSuccess) {
      token = authState.token;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: FutureBuilder<List<Event>>(
        future: _fetchEvents(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isDeleting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load events: \n${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          final events = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event: event, token: token);
            },
          );
        },
      ),
      backgroundColor: Color(0xFFF5F5F5),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context),
      ),
    );
  }

  Widget _buildEventCard({required Event event, String? token}) {
    // Parse event date and format for display
    final DateTime eventDateTime = DateTime.parse(event.eventDate);
    final String month = DateFormat('MMM').format(eventDateTime).toUpperCase();
    final String day = DateFormat('dd').format(eventDateTime);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                    event.eventTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                      ),
                      const SizedBox(height: 4), // Add some spacing
                      Text(
                        event.eventLocation,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Location
            // Removed the old Location Padding here
            // Padding(
            //   padding: const EdgeInsets.only(left: 24), // Align with title
            //   child: Text(
            //     event.eventLocation,
            //     style: const TextStyle(color: Colors.black, fontSize: 14),
            //   ),
            // ),
            const SizedBox(height: 16),
            // Time and Buttons
            Row(
              children: [
                Text(
                  event.eventTime,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () async {
                    context.go('/admin/edit-event/${event.eventId}');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    backgroundColor: Color(0xFFD58787),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
              onPressed:
                  _isDeleting && _deletingEventId == event.eventId
                      ? null
                      : () => _confirmDelete(context, event.eventId!, token),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                backgroundColor: Color(0xFFD58787),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(double.infinity, 50),
              ),
              child:
                  _isDeleting && _deletingEventId == event.eventId
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Cancel Event',
                        style: TextStyle(color: Colors.white),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/events')) return 1;
  if (location.startsWith('/registered')) return 2;
  if (location.startsWith('/articles')) return 3;
  if (location.startsWith('/profile')) return 4;
  if (location.startsWith('/admin/add')) return 5;
  return 0;
}

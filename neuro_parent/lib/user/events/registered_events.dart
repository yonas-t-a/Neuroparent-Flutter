import 'package:flutter/material.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_event_bloc.dart'; // For fetching all events
import '../bloc/user_user_event_bloc.dart'; // For managing registered events
import '../../models/event.dart'; // For the Event model
import 'package:intl/intl.dart'; // For date formatting
import 'package:collection/collection.dart'; // For firstWhereOrNull

class RegisteredEventsScreen extends ConsumerStatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  ConsumerState<RegisteredEventsScreen> createState() =>
      _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState
    extends ConsumerState<RegisteredEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all events (needed to get full Event details for registered event IDs)
    Future.microtask(() => ref.read(userEventProvider.notifier).fetchEvents());
    // Fetch user's registered event IDs
    Future.microtask(
      () => ref.read(userUserEventProvider.notifier).fetchRegisteredEvents(),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/registered')) return 2;
    if (location.startsWith('/articles')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final userEventState = ref.watch(userEventProvider);
    final userUserEventState = ref.watch(userUserEventProvider);

    final isLoading = userEventState.isLoading || userUserEventState.isLoading;
    final error = userEventState.error ?? userUserEventState.error;

    // Filter events to show only those the user has registered for
    final List<Event> registeredEvents =
        userEventState.events.where((event) {
          return event.eventId != null &&
              userUserEventState.registeredEventIds.contains(event.eventId!);
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/events'),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Registered Events',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (error != null)
                Expanded(child: Center(child: Text('Error: $error'))),
              if (!isLoading && error == null)
                Expanded(
                  child:
                      registeredEvents.isEmpty
                          ? const Center(
                            child: Text('No registered events found.'),
                          )
                          : ListView.builder(
                            itemCount: registeredEvents.length,
                            itemBuilder: (context, index) {
                              final event = registeredEvents[index];
                              return RegisteredEventCard(
                                event: event,
                                onCancelTap:
                                    () =>
                                        _showCancelConfirmation(context, event),
                                onTap: () {
                                  final int? eventIdForNavigation =
                                      event.eventId;
                                  if (eventIdForNavigation == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cannot view event details: Event ID is missing.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  context.go(
                                    '/events/${eventIdForNavigation}',
                                  );
                                },
                              );
                            },
                          ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Event'),
            content: Text(
              'Are you sure you want to cancel your registration for \'${event.eventTitle}\'?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  if (event.eventId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cannot cancel registration: Event ID is missing.',
                        ),
                      ),
                    );
                    return;
                  }

                  final userEventNotifier = ref.read(
                    userUserEventProvider.notifier,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cancelling registration for ${event.eventTitle}...',
                      ),
                    ),
                  );
                  await userEventNotifier.unregisterEvent(event.eventId!);
                  if (!mounted) return;

                  final currentUserEventState = ref.read(userUserEventProvider);
                  if (currentUserEventState.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registration for ${event.eventTitle} cancelled successfully!',
                        ),
                      ),
                    );
                    // No need to pop here, the list will re-render
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to cancel registration: ${currentUserEventState.error}',
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }
}

class RegisteredEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onCancelTap;
  final VoidCallback onTap;

  const RegisteredEventCard({
    super.key,
    required this.event,
    required this.onCancelTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String month = '';
    String day = '';
    try {
      final dt = DateTime.parse(event.eventDate);
      month = DateFormat('MMM').format(dt);
      day = DateFormat('d').format(dt);
    } catch (e) {
      month = '';
      day = '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.eventLocation,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.eventTime,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCancelTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD67E7E),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 42,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: const Text(
                'Cancel Event',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

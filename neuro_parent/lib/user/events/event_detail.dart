import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_event_bloc.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../bloc/user_user_event_bloc.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final int eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userEventProvider.notifier).fetchEventById(widget.eventId),
    );
    Future.microtask(
      () => ref.read(userUserEventProvider.notifier).fetchRegisteredEvents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEventState = ref.watch(userEventProvider);
    final userUserEventState = ref.watch(userUserEventProvider);

    final event = userEventState.events.firstWhereOrNull(
      (e) => e.eventId == widget.eventId,
    );

    final isLoading = userEventState.isLoading || userUserEventState.isLoading;
    final error = userEventState.error ?? userUserEventState.error;
    final isRegistered =
        event != null &&
        userUserEventState.registeredEventIds.contains(event.eventId);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/events');
            },
          ),
        ),
        body: Center(child: Text('Error: $error')),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/events');
            },
          ),
        ),
        body: const Center(child: Text('Event not found.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.go('/events');
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.eventTitle,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FractionColumnWidth(0.3),
                  1: FractionColumnWidth(0.7),
                },
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(DateTime.parse(event.eventDate)),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Time'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(event.eventTime),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Location'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(event.eventLocation),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(event.eventDescription),
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final userEventNotifier = ref.read(
                      userUserEventProvider.notifier,
                    );
                    if (isRegistered) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unregistering from ${event.eventTitle}...',
                          ),
                        ),
                      );
                      await userEventNotifier.unregisterEvent(event.eventId!);
                      if (!mounted) return;

                      final currentUserEventState = ref.read(
                        userUserEventProvider,
                      );
                      if (currentUserEventState.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unregistered from ${event.eventTitle} successfully!',
                            ),
                          ),
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to unregister: ${currentUserEventState.error}',
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Registering for ${event.eventTitle}...',
                          ),
                        ),
                      );
                      await userEventNotifier.registerEvent(event.eventId!);
                      if (!mounted) return;

                      final currentUserEventState = ref.read(
                        userUserEventProvider,
                      );
                      if (currentUserEventState.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Registered for ${event.eventTitle} successfully!',
                            ),
                          ),
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to register: ${currentUserEventState.error}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRegistered
                            ? const Color(0xFFD58787)
                            : const Color(0xFFBEEBF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    isRegistered ? 'Cancel Event' : 'Register',
                    style: TextStyle(
                      color: isRegistered ? Colors.white : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context) - 1,
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context) {
  return 1;
}

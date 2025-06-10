// Requires intl package. Add intl: ^0.18.0 (or latest) to pubspec.yaml.
import 'package:flutter/material.dart';
import 'package:neuro_parent/user/events/event_detail.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/core/categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_event_bloc.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';
import '../bloc/user_user_event_bloc.dart';
import '../../auth/auth_bloc.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/registered')) return 2;
    if (location.startsWith('/articles')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  String _selectedRegistrationFilter = 'ALL';

  bool _isAfterSelectedDate(String eventDate) {
    if (_selectedDate == null) return true;
    try {
      final eventDt = DateTime.parse(eventDate);
      return !eventDt.isBefore(_selectedDate!);
    } catch (e) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userEventProvider.notifier).fetchEvents());
    Future.microtask(
      () => ref.read(userUserEventProvider.notifier).fetchRegisteredEvents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEventState = ref.watch(userEventProvider);
    final userUserEventState = ref.watch(userUserEventProvider);
    final events = userEventState.events;
    final isLoading = userEventState.isLoading || userUserEventState.isLoading;
    final error = userEventState.error ?? userUserEventState.error;

    List<Event> filteredEvents =
        events.where((event) {
          final matchesSearch = event.eventTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == 'ALL' ||
              event.eventCategory == _selectedCategory;
          final matchesDate = _isAfterSelectedDate(event.eventDate);


          final bool
          eventIsRegistered = userUserEventState.registeredEventIds.contains(
            event.eventId,
          ); 
          final bool matchesRegistrationFilter;
          if (_selectedRegistrationFilter == 'REGISTERED') {
            matchesRegistrationFilter = eventIsRegistered;
          } else if (_selectedRegistrationFilter == 'UNREGISTERED') {
            matchesRegistrationFilter = !eventIsRegistered;
          } else {
            matchesRegistrationFilter = true; 
          }

          return matchesSearch &&
              matchesCategory &&
              matchesDate &&
              matchesRegistrationFilter;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Events',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search events',
                        filled: true,
                        fillColor: Color(0xFFF3F6FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F6FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2050),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    _selectedDate = selectedDate;
                                  });
                                }
                              },
                              child: const Icon(Icons.calendar_today_outlined),
                            );
                          },
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            tooltip: 'Clear date filter',
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 12,
                children: [
                  _buildRegistrationFilterChip('UNREGISTERED', 'Unregistered'),
                  _buildRegistrationFilterChip('REGISTERED', 'Registered'),
                ],
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (String category in Categories.allCategories) ...[
                      _buildCategoryChip(category),
                      const SizedBox(width: 8.0),
                    ],
                  ],
                ),
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
                      filteredEvents.isEmpty
                          ? const Center(child: Text('No events found.'))
                          : ListView.builder(
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              final int? currentEventId = event.eventId;
                              final isRegistered =
                                  currentEventId != null &&
                                  userUserEventState.registeredEventIds
                                      .contains(currentEventId);
                              return EventCard(
                                event: event,
                                isRegistered: isRegistered,
                                onRegisterTap: () async {
                                  if (currentEventId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cannot register/unregister: Event ID is missing.',
                                        ),
                                      ),
                                    );
                                    return; 
                                  }

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
                                    await userEventNotifier.unregisterEvent(
                                      currentEventId,
                                    );
                                    if (!mounted) return;
                                    if (userUserEventState.error == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Unregistered from ${event.eventTitle} successfully!',
                                          ),
                                        ), 
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to unregister: ${userUserEventState.error}',
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
                                    await userEventNotifier.registerEvent(
                                      currentEventId,
                                    );
                                    if (!mounted) return;
                                    if (userUserEventState.error == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Registered for ${event.eventTitle} successfully!',
                                          ),
                                        ), 
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to register: ${userUserEventState.error}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
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

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory.toUpperCase() == label.toUpperCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (label.toUpperCase() == 'ALL') {
            _selectedCategory = 'ALL';
          } else {
            if (selected) {
              _selectedCategory = label;
            } else {
              _selectedCategory = 'ALL';
            }
          }
        });
      },
      backgroundColor: Color(0xFFF3F6FC),
      selectedColor: const Color(0xFF1976D2),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildRegistrationFilterChip(String filter, String label) {
    final isSelected =
        _selectedRegistrationFilter.toUpperCase() == filter.toUpperCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedRegistrationFilter == filter) {
            _selectedRegistrationFilter = 'ALL'; 
          } else {
            _selectedRegistrationFilter = filter; 
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFEAF1FC), 
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final bool isRegistered;
  final VoidCallback onRegisterTap;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onRegisterTap,
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
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  Text(
                    event.eventLocation,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.eventTime,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: onRegisterTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isRegistered
                                    ? Color(0xFFF3F6FC)
                                    : const Color(0xFFBEEBF2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            isRegistered ? 'Unregister' : 'Register',
                            style: TextStyle(
                              color:
                                  isRegistered
                                      ? Color.fromARGB(255, 107, 219, 236)
                                      : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

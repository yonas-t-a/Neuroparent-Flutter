import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../services/event_service.dart';
import '../../auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
// Import for firstWhereOrNull

class EditMyEventPage extends ConsumerStatefulWidget {
  final int eventId; // Changed from Event event
  const EditMyEventPage({super.key, required this.eventId});

  @override
  ConsumerState<EditMyEventPage> createState() => _EditMyEventPageState();
}

class _EditMyEventPageState extends ConsumerState<EditMyEventPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;
  Event? _currentEvent; // To store the fetched event

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized once the event is fetched in _fetchEventAndInitControllers
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchEventAndInitControllers();
  }

  Future<void> _fetchEventAndInitControllers() async {
    final authState = ref.read(authProvider);
    String? token;
    if (authState is AuthSuccess) {
      token = authState.token;
    }
    if (token == null) {
      // Handle error: No token available
      // print("Error: No JWT token available for fetching event.");
      return;
    }

    final eventRepository = EventRepository(
      eventService: EventService(jwtToken: token),
    );

    try {
      final fetchedEvent = await eventRepository.getEventById(widget.eventId);
      setState(() {
        _currentEvent = fetchedEvent;
        selectedCategory = _currentEvent!.eventCategory;
        _dateController.text = _currentEvent!.eventDate;
        _timeController.text = _currentEvent!.eventTime;
        _titleController.text = _currentEvent!.eventTitle;
        _locationController.text = _currentEvent!.eventLocation;
        _descriptionController.text = _currentEvent!.eventDescription;
      });
    } catch (e) {
      // print("Error fetching event: $e");
      // Optionally show an error to the user
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? _currentEvent?.eventDateAsDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          selectedTime ??
          _currentEvent?.eventTimeAsTimeOfDay ??
          TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _timeController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> _submitForm({
    required String token,
    required int creatorId,
  }) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentEvent == null) return; // Should not happen if event is loaded

      setState(() => _isLoading = true);
      final updatedEvent = Event(
        eventId: _currentEvent!.eventId,
        eventTitle: _titleController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        eventDate: _dateController.text,
        eventTime: _timeController.text,
        eventLocation: _locationController.text.trim(),
        eventCategory: selectedCategory ?? '',
        creatorId: creatorId,
      );
      final eventRepository = EventRepository(
        eventService: EventService(jwtToken: token),
      );
      try {
        await eventRepository.updateEvent(updatedEvent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully!')),
          );
          context.pop(true); // Use context.pop for GoRouter
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: \n${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    bool enabled = true,
    int maxLines = 1,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEvent == null && !_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading while fetching
    }

    final authState = ref.watch(authProvider);
    if (authState is AuthLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (authState is AuthSuccess && authState.token != null) {
      final String token = authState.token!;
      final int creatorId = authState.user.userId;
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/admin/add'),
                        child: Text("Cancel", style: TextStyle(fontSize: 16)),
                      ),
                      Text(
                        "Edit Event",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 60),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    "Title",
                    controller: _titleController,
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Location",
                    controller: _locationController,
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: _inputDecoration("Date"),
                          validator:
                              (v) => v == null || v.isEmpty ? "Required" : null,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.blue),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: _inputDecoration("Time"),
                          validator:
                              (v) => v == null || v.isEmpty ? "Required" : null,
                          onTap: () => _selectTime(context),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.access_time, color: Colors.blue),
                        onPressed: () => _selectTime(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Category"),
                    value: selectedCategory,
                    items:
                        [
                              'ASD',
                              'ADHD',
                              'Dyslexia',
                              'Dyscalculia',
                              'Dyspraxia',
                              'Tourette Syndrome',
                              'OCD',
                              'Bipolar',
                              'Anxiety',
                            ]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    "Description",
                    controller: _descriptionController,
                    maxLines: 4,
                    validator:
                        (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () =>
                                _submitForm(token: token, creatorId: creatorId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              "Update Event",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: UserBottomNav(
          currentIndex: _getCurrentIndex(context),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'You must be logged in as admin to edit an event. \n${authState.toString()}',
          ),
        ),
      );
    }
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

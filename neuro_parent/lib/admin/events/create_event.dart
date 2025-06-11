import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../services/event_service.dart';
import '../../auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _eventCreated = false;

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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
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
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
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
      setState(() {
        _isLoading = true;
        _eventCreated = false;
      });
      final event = Event(
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
        await eventRepository.createEvent(event);
        if (mounted) {
          setState(() {
            _eventCreated = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: \n${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState is AuthLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.go('/admin/add');
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Text(
                        "New Event",
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
                        _isLoading || _eventCreated
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
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _eventCreated ? 'Event Created' : 'Add Event',
                              style: const TextStyle(
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
            'You must be logged in as admin to create an event. ${authState.toString()}',
          ),
        ),
      );
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



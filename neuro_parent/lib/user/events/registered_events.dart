import 'package:flutter/material.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_event_bloc.dart'; // For fetching all events
import '../bloc/user_user_event_bloc.dart'; // For managing registered events
import '../../models/event.dart'; // For the Event model
import 'package:intl/intl.dart'; // For date formatting
import 'package:collection/collection.dart'; // For firstWhereOrNull

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

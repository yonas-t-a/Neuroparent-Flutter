import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Event {
  final int? eventId;
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventCategory;
  final int? creatorId;
  final int? eventStatus;

  Event({
    this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventCategory,
    this.creatorId,
    this.eventStatus,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse event_date to ensure it's always in YYYY-MM-DD format
    String parsedDate = json['event_date'];
    try {
      final DateTime dateTime = DateTime.parse(parsedDate);
      parsedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      print(
        "Warning: Could not parse event_date '${json['event_date']}'. Using raw string. Error: $e",
      );
    }

    return Event(
      eventId: json['event_id'] as int?,
      eventTitle: json['event_title'],
      eventDescription: json['event_description'],
      eventDate: parsedDate,
      eventTime: json['event_time'],
      eventLocation: json['event_location'],
      eventCategory: json['event_category'],
      creatorId: json['creator_id'] as int?,
      eventStatus: json['event_status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': eventTitle,
      'description': eventDescription,
      'date': eventDate,
      'time': eventTime,
      'location': eventLocation,
      'category': eventCategory,
      if (creatorId != null) 'creator_id': creatorId,
    };
  }

  DateTime get eventDateAsDateTime {
    return DateTime.parse(eventDate);
  }

  TimeOfDay get eventTimeAsTimeOfDay {
    final parts = eventTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

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
    return Event(
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      eventDescription: json['event_description'],
      eventDate: json['event_date'],
      eventTime: json['event_time'],
      eventLocation: json['event_location'],
      eventCategory: json['event_category'],
      creatorId: json['creator_id'],
      eventStatus: json['event_status'],
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
}

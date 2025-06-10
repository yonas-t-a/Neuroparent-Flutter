class UserEvent {
  final int? userEventId;
  final int? userId;
  final int? eventId;

  UserEvent({this.userEventId, this.userId, this.eventId});

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      userEventId: json['user_event_id'] as int?,
      userId: json['user_id'] as int?,
      eventId: json['event_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_event_id': userEventId,
      'user_id': userId,
      'event_id': eventId,
    };
  }
}

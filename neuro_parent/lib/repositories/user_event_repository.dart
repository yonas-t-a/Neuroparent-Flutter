import '../services/user_event_service.dart';
import '../models/user_event.dart';


class UserEventRepository {
  final UserEventService userEventService;

  UserEventRepository({required this.userEventService});

  Future<UserEvent> createUserEvent(int userId, int eventId) async {
    try {
      return await userEventService.createUserEvent(userId, eventId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserEvent(int userEventId) async {
    try {
      await userEventService.deleteUserEvent(userEventId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserEvent>> fetchUserEventsByUserId(int userId) async {
    try {
      final allUserEvents = await userEventService.fetchUserEventsByUserId(
        userId,
      );
      return allUserEvents.where((ue) => ue.userId == userId).toList();
    } catch (e) {
      rethrow;
    }
  }


  
}

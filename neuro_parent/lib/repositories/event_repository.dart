import '../models/event.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService eventService;
  EventRepository({required this.eventService});

  Future<List<Event>> getEvents() => eventService.getEvents();
  Future<Event> getEventById(int id) => eventService.getEventById(id);
  Future<void> createEvent(Event event) => eventService.createEvent(event);
  // Add more methods as needed
}

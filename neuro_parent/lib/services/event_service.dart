import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  static const String baseUrl = 'http://localhost:3500/api/events';

  final String? jwtToken;
  EventService({this.jwtToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
  };

  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> getEventById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<void> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: json.encode(event.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  // Add updateEvent, deleteEvent, getByCategory, getByDate, getByLocation as needed
}

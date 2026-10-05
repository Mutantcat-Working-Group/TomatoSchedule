import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/task.dart';

class AiService {
  final String apiKey;
  final String baseUrl;

  AiService({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
  });

  Future<List<ScheduleEvent>> generateSchedule({
    required String userInput,
    required List<ScheduleEvent> existingEvents,
    required List<Task> tasks,
  }) async {
    final prompt = _buildPrompt(userInput, existingEvents, tasks);

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an AI scheduling assistant. Analyze the user\'s request and generate a schedule. Return events in JSON format.'
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return _parseEvents(content, existingEvents);
    } else {
      throw Exception('AI request failed: ${response.statusCode}');
    }
  }

  String _buildPrompt(
    String userInput,
    List<ScheduleEvent> existingEvents,
    List<Task> tasks,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('User request: $userInput');
    buffer.writeln('');
    buffer.writeln('Existing events:');
    for (final event in existingEvents) {
      buffer.writeln(
          '- ${event.title}: ${event.startTime} to ${event.endTime}');
    }
    buffer.writeln('');
    buffer.writeln('Tasks to schedule:');
    for (final task in tasks) {
      buffer.writeln(
          '- ${task.title} (est: ${task.estimatedMinutes}min, priority: ${task.priority})');
    }
    buffer.writeln('');
    buffer.writeln(
        'Please generate a schedule as a JSON array of events with: title, startTime (ISO8601), endTime (ISO8601), priority (low/medium/high/urgent)');
    return buffer.toString();
  }

  List<ScheduleEvent> _parseEvents(
      String content, List<ScheduleEvent> existingEvents) {
    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
      if (jsonMatch == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonMatch.group(0)!);
      return jsonList.map((json) {
        return ScheduleEvent(
          title: json['title'] ?? 'Untitled',
          startTime: DateTime.parse(json['startTime']),
          endTime: DateTime.parse(json['endTime']),
          priority: _parsePriority(json['priority']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  EventPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return EventPriority.urgent;
      case 'high':
        return EventPriority.high;
      case 'low':
        return EventPriority.low;
      default:
        return EventPriority.medium;
    }
  }
}

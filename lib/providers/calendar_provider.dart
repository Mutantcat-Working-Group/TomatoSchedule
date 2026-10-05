import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(apiKey: 'YOUR_API_KEY_HERE');
});

final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<ScheduleEvent>>>((ref) {
  final db = ref.watch(databaseProvider);
  return EventsNotifier(db);
});

class EventsNotifier extends StateNotifier<AsyncValue<List<ScheduleEvent>>> {
  final DatabaseService _db;

  EventsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 30));
      final events = await _db.getEvents(start, end);
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEvent(ScheduleEvent event) async {
    await _db.insertEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    await _db.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _db.deleteEvent(id);
    await loadEvents();
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final db = ref.watch(databaseProvider);
  return TasksNotifier(db);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final DatabaseService _db;

  TasksNotifier(this._db) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await _db.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(Task task) async {
    await _db.insertTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    await loadTasks();
  }
}

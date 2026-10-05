import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final int estimatedMinutes;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.deadline,
    this.estimatedMinutes = 30,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    int? estimatedMinutes,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.millisecondsSinceEpoch,
      'estimatedMinutes': estimatedMinutes,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
          : null,
      estimatedMinutes: map['estimatedMinutes'] as int,
      priority: TaskPriority.values[map['priority'] as int],
      status: TaskStatus.values[map['status'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { todo, inProgress, done, cancelled }

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int assignedTo;

  @HiveField(3)
  String priority;

  @HiveField(4)
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.priority,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assigned_to': assignedTo,
      'priority': priority,
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      assignedTo: json['assigned_to'] as int,
      priority: json['priority'] as String,
      completed: json['completed'] as bool,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, assignedTo: $assignedTo, priority: $priority, completed: $completed)';
  }
}

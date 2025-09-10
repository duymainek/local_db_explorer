import 'package:hive/hive.dart';

part 'post.g.dart';

@HiveType(typeId: 1)
class Post extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, title: $title)';
  }
}

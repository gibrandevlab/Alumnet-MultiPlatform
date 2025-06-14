import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String message;

  @HiveField(3)
  String? mediaPath;

  @HiveField(4)
  String? mediaType;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? userName;

  Message({
    required this.id,
    required this.userId,
    required this.message,
    this.mediaPath,
    this.mediaType,
    required this.createdAt,
    this.userName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        id: json['id'],
        userId: json['user_id'],
        message: json['message'] ?? '',
        mediaPath: json['media_path']?.toString(),
        mediaType: json['media_type']?.toString(),
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
        userName: json['user_name']?.toString(),
      );
    } catch (e) {
      print('Error parsing Message: $e, data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'message': message,
        'media_path': mediaPath,
        'media_type': mediaType,
        'created_at': createdAt.toIso8601String(),
        'user_name': userName,
      };
}

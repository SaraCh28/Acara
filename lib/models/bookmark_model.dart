class BookmarkModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

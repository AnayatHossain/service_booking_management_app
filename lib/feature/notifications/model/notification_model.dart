class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'promo', 'system', 'reminder'
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}

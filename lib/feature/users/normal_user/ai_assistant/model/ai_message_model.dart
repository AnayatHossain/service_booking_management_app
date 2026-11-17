import '../../home_screen/model/service_model.dart';

class AiMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;
  final List<ServiceModel> suggestedServices;
  final List<String> suggestedQuestions;

  AiMessage({
    String? id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.suggestedServices = const [],
    this.suggestedQuestions = const [],
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  bool get isUser => role == 'user';

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    final rawServices = json['suggested_services'] as List<dynamic>? ??
        json['recommended_services'] as List<dynamic>? ??
        [];
    final rawQuestions = json['suggested_questions'] as List<dynamic>? ?? [];

    DateTime parsedDate;
    try {
      parsedDate = json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AiMessage(
      id: json['id']?.toString(),
      role: json['role']?.toString() ?? 'assistant',
      text: json['text']?.toString() ?? json['content']?.toString() ?? json['reply']?.toString() ?? '',
      timestamp: parsedDate,
      suggestedServices: rawServices
          .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      suggestedQuestions: rawQuestions.map((q) => q.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class AiSessionModel {
  final String id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;
  final String lastMessage;

  AiSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.lastMessage,
  });

  factory AiSessionModel.fromJson(Map<String, dynamic> json) {
    return AiSessionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Chat Session',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      messageCount: (json['message_count'] is num) ? (json['message_count'] as num).toInt() : 0,
      lastMessage: json['last_message']?.toString() ?? '',
    );
  }
}

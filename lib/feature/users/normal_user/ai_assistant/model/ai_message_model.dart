import '../../home_screen/model/service_model.dart';

class AiMessage {
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;
  final List<ServiceModel> suggestedServices;
  final List<String> suggestedQuestions;

  AiMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.suggestedServices = const [],
    this.suggestedQuestions = const [],
  });

  bool get isUser => role == 'user';
}

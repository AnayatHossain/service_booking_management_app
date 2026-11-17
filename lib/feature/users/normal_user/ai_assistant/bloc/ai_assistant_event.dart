import 'package:equatable/equatable.dart';

abstract class AIAssistantEvent extends Equatable {
  const AIAssistantEvent();

  @override
  List<Object?> get props => [];
}

class AISendMessageRequested extends AIAssistantEvent {
  final String message;
  const AISendMessageRequested(this.message);

  @override
  List<Object?> get props => [message];
}

class AIFetchSessionsRequested extends AIAssistantEvent {
  const AIFetchSessionsRequested();
}

class AICreateSessionRequested extends AIAssistantEvent {
  final String title;
  const AICreateSessionRequested({this.title = 'New Chat'});

  @override
  List<Object?> get props => [title];
}

class AISelectSessionRequested extends AIAssistantEvent {
  final String sessionId;
  const AISelectSessionRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class AIDeleteSessionRequested extends AIAssistantEvent {
  final String sessionId;
  const AIDeleteSessionRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class AIClearChatRequested extends AIAssistantEvent {
  const AIClearChatRequested();
}

class AIClearAllSessionsRequested extends AIAssistantEvent {
  const AIClearAllSessionsRequested();
}

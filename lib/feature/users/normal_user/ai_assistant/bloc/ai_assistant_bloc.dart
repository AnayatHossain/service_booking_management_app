import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import '../model/ai_message_model.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  static AiMessage get _defaultGreetingMessage => AiMessage(
        role: 'assistant',
        text: "Hello! I'm your AI Service Booking Assistant. How can I help you today? Ask me about available services, pricing, recommendations, or booking instructions!",
        timestamp: DateTime.now(),
        suggestedQuestions: const [
          'What cleaning services do you have?',
          'How much is AC servicing?',
          'I need a plumber right now',
        ],
      );

  AIAssistantBloc()
      : super(AIAssistantState(
          messages: [_defaultGreetingMessage],
        )) {
    on<AISendMessageRequested>(_onSendMessage);
    on<AIFetchSessionsRequested>(_onFetchSessions);
    on<AICreateSessionRequested>(_onCreateSession);
    on<AISelectSessionRequested>(_onSelectSession);
    on<AIDeleteSessionRequested>(_onDeleteSession);
    on<AIClearAllSessionsRequested>(_onClearAllSessions);
    on<AIClearChatRequested>(_onClearChat);
    on<AIRefreshRequested>(_onRefresh);

    // Fetch sessions automatically when bloc starts
    add(const AIFetchSessionsRequested());
  }

  Future<void> _onFetchSessions(
      AIFetchSessionsRequested event, Emitter<AIAssistantState> emit) async {
    emit(state.copyWith(isLoadingSessions: true));
    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiSessions,
        apiType: ApiType.get,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final list = (response.data['data'] as List<dynamic>)
            .map((item) => AiSessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(sessions: list, isLoadingSessions: false));
      } else {
        emit(state.copyWith(isLoadingSessions: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingSessions: false));
    }
  }

  Future<void> _onCreateSession(
      AICreateSessionRequested event, Emitter<AIAssistantState> emit) async {
    emit(state.copyWith(
      messages: [_defaultGreetingMessage],
      currentSessionId: null,
      currentSessionTitle: 'New Chat',
      isLoading: false,
    ));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiSessions,
        apiType: ApiType.post,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({'title': event.title}),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        final newSessionId = data['id']?.toString();
        emit(state.copyWith(
          currentSessionId: newSessionId,
          currentSessionTitle: data['title'] ?? 'New Chat',
        ));
        add(const AIFetchSessionsRequested());
      }
    } catch (_) {}
  }

  Future<void> _onSelectSession(
      AISelectSessionRequested event, Emitter<AIAssistantState> emit) async {
    emit(state.copyWith(isLoading: true, currentSessionId: event.sessionId));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiSessionDetails(event.sessionId),
        apiType: ApiType.get,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        final rawMessages = (data['messages'] as List<dynamic>? ?? []);
        final parsed = rawMessages
            .map((m) => AiMessage.fromJson(m as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          messages: parsed.isNotEmpty ? parsed : [_defaultGreetingMessage],
          currentSessionId: event.sessionId,
          currentSessionTitle: data['title'] ?? 'Chat',
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onDeleteSession(
      AIDeleteSessionRequested event, Emitter<AIAssistantState> emit) async {
    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiDeleteSession(event.sessionId),
        apiType: ApiType.delete,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      await api.call();

      final updated = state.sessions.where((s) => s.id != event.sessionId).toList();
      if (state.currentSessionId == event.sessionId) {
        emit(state.copyWith(
          sessions: updated,
          messages: [_defaultGreetingMessage],
          currentSessionId: null,
          currentSessionTitle: 'New Chat',
        ));
      } else {
        emit(state.copyWith(sessions: updated));
      }
    } catch (_) {}
  }

  Future<void> _onClearAllSessions(
      AIClearAllSessionsRequested event, Emitter<AIAssistantState> emit) async {
    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiClearSessions,
        apiType: ApiType.delete,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      await api.call();

      emit(state.copyWith(
        sessions: const [],
        messages: [_defaultGreetingMessage],
        currentSessionId: null,
        currentSessionTitle: 'New Chat',
      ));
    } catch (_) {}
  }

  Future<void> _onSendMessage(
      AISendMessageRequested event, Emitter<AIAssistantState> emit) async {
    final text = event.message.trim();
    if (text.isEmpty) return;

    final userMessage = AiMessage(
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<AiMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(messages: updatedMessages, isLoading: true, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiChat,
        apiType: ApiType.post,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({
          'message': text,
          if (state.currentSessionId != null && state.currentSessionId!.isNotEmpty)
            'session_id': state.currentSessionId,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        final aiText = data['reply'] ?? data['response'] ?? 'I could not process your request at this moment.';
        final rawServices = (data['suggested_services'] ?? data['recommended_services']) as List<dynamic>? ?? [];
        final rawQuestions = data['suggested_questions'] as List<dynamic>? ?? [];
        final newSessionId = data['session_id']?.toString() ?? state.currentSessionId;
        final sessionTitle = data['session_title']?.toString() ?? state.currentSessionTitle;

        final services = rawServices
            .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
            .toList();
        final questions = rawQuestions.map((q) => q.toString()).toList();

        final botMessage = AiMessage(
          role: 'assistant',
          text: aiText,
          timestamp: DateTime.now(),
          suggestedServices: services,
          suggestedQuestions: questions,
        );

        emit(state.copyWith(
          messages: List<AiMessage>.from(state.messages)..add(botMessage),
          isLoading: false,
          currentSessionId: newSessionId,
          currentSessionTitle: sessionTitle,
        ));

        // Refresh sessions list in background to reflect new chat title/activity
        add(const AIFetchSessionsRequested());
      } else {
        final botMessage = AiMessage(
          role: 'assistant',
          text: response.errorMessage ?? "I'm having trouble connecting right now. Please try again in a moment.",
          timestamp: DateTime.now(),
        );
        emit(state.copyWith(
          messages: List<AiMessage>.from(state.messages)..add(botMessage),
          isLoading: false,
        ));
      }
    } catch (e) {
      final botMessage = AiMessage(
        role: 'assistant',
        text: "Connection error: $e",
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: List<AiMessage>.from(state.messages)..add(botMessage),
        isLoading: false,
      ));
    }
  }

  void _onClearChat(AIClearChatRequested event, Emitter<AIAssistantState> emit) {
    emit(state.copyWith(
      messages: [_defaultGreetingMessage],
      currentSessionId: null,
      currentSessionTitle: 'New Chat',
    ));
  }

  Future<void> _onRefresh(
      AIRefreshRequested event, Emitter<AIAssistantState> emit) async {
    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiSessions,
        apiType: ApiType.get,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final response = await api.call();
      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final list = (response.data['data'] as List<dynamic>)
            .map((item) => AiSessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(sessions: list));
      }
    } catch (_) {}

    if (state.currentSessionId != null && state.currentSessionId!.isNotEmpty) {
      try {
        final token = await Urls.rawToken;
        final api = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.aiSessionDetails(state.currentSessionId!),
          apiType: ApiType.get,
          apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final response = await api.call();
        if (response.isSuccess && response.data is Map && response.data['data'] != null) {
          final data = response.data['data'];
          final rawMessages = (data['messages'] as List<dynamic>? ?? []);
          final parsed = rawMessages
              .map((m) => AiMessage.fromJson(m as Map<String, dynamic>))
              .toList();
          emit(state.copyWith(
            messages: parsed.isNotEmpty ? parsed : [_defaultGreetingMessage],
            currentSessionTitle: data['title'] ?? state.currentSessionTitle,
          ));
        }
      } catch (_) {}
    }
  }
}

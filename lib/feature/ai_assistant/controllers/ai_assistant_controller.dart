import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import '../model/ai_message_model.dart';

class AiAssistantController extends GetxController {
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  var messages = <AiMessage>[].obs;
  var quickPrompts = <String>[].obs;
  var isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAssistant();
    fetchQuickPrompts();
  }

  void _initializeAssistant() {
    messages.add(
      AiMessage(
        role: 'assistant',
        text: "Hello! 👋 I'm ServiceBot, your AI booking assistant. How can I help you today? You can ask about our available services, get tailored recommendations, or check pricing and durations!",
        timestamp: DateTime.now(),
        suggestedQuestions: [
          "What are your top recommended services?",
          "Can you suggest a home cleaning service?",
          "How do I cancel an appointment?"
        ],
      ),
    );
  }

  Future<void> fetchQuickPrompts() async {
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiPrompts,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        quickPrompts.value = list.map((e) => e.toString()).toList();
      }
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || isTyping.value) return;

    inputController.clear();

    // 1. Add User Message
    messages.add(
      AiMessage(
        role: 'user',
        text: query,
        timestamp: DateTime.now(),
      ),
    );
    _scrollToBottom();

    try {
      isTyping.value = true;

      // Build conversation history
      final historyPayload = messages
          .take(messages.length - 1)
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.aiChat,
        apiType: ApiType.post,
        apiBody: ApiBody.json({
          'message': query,
          'history': historyPayload,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data['data'] != null) {
        final data = response.data['data'];
        final replyText = data['reply'] ?? "I'm here to help you explore our services!";
        
        List<ServiceModel> suggestions = [];
        if (data['suggested_services'] != null) {
          final List<dynamic> rawList = data['suggested_services'];
          suggestions = rawList.map((item) => ServiceModel.fromJson(item)).toList();
        }

        List<String> nextQuestions = [];
        if (data['suggested_questions'] != null) {
          final List<dynamic> qList = data['suggested_questions'];
          nextQuestions = qList.map((e) => e.toString()).toList();
        }

        messages.add(
          AiMessage(
            role: 'assistant',
            text: replyText,
            timestamp: DateTime.now(),
            suggestedServices: suggestions,
            suggestedQuestions: nextQuestions,
          ),
        );
      } else {
        messages.add(
          AiMessage(
            role: 'assistant',
            text: "I encountered a minor issue processing your request, but I'm still here to help! Please check our home screen to browse our services.",
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      messages.add(
        AiMessage(
          role: 'assistant',
          text: "Connection note: Please ensure the backend server is running. You can explore services directly from the home tab.",
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

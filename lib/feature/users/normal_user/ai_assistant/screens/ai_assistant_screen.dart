import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../widgets/ai_chat_bubble.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIAssistantBloc(),
      child: BlocConsumer<AIAssistantBloc, AIAssistantState>(
        listener: (context, state) {
          _scrollToBottom();
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Service Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Powered by Gemini AI',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                  tooltip: 'Clear Chat',
                  onPressed: () {
                    context.read<AIAssistantBloc>().add(const AIClearChatRequested());
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Chat Message List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return AiChatBubble(
                        message: message,
                        onQuestionTap: (q) {
                          context.read<AIAssistantBloc>().add(AISendMessageRequested(q));
                        },
                      );
                    },
                  ),
                ),

                // Typing indicator
                if (state.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI is thinking...',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.8), fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                // Quick Prompt Chips
                if (state.messages.length <= 2)
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.quickPrompts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final prompt = state.quickPrompts[index];
                        return ActionChip(
                          label: Text(prompt, style: const TextStyle(fontSize: 12, color: AppColors.primaryColor)),
                          backgroundColor: AppColors.primaryLight.withOpacity(0.4),
                          side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onPressed: () {
                            context.read<AIAssistantBloc>().add(AISendMessageRequested(prompt));
                          },
                        );
                      },
                    ),
                  ),

                // Input Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.strokeColor.withOpacity(0.8))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.strokeColor),
                          ),
                          child: TextField(
                            controller: _inputController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Ask for service recommendations...',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                context.read<AIAssistantBloc>().add(AISendMessageRequested(val.trim()));
                                _inputController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  final text = _inputController.text.trim();
                                  if (text.isNotEmpty) {
                                    context.read<AIAssistantBloc>().add(AISendMessageRequested(text));
                                    _inputController.clear();
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

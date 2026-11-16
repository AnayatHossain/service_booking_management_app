import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../controllers/ai_assistant_controller.dart';
import '../widgets/ai_chat_bubble.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiAssistantController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Service Assistant',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Powered by Google Gemini',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick prompt chips bar
          Obx(() {
            if (controller.quickPrompts.isNotEmpty) {
              return Container(
                height: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.quickPrompts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final prompt = controller.quickPrompts[index];
                    return ActionChip(
                      label: Text(
                        prompt,
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppColors.primaryLight.withOpacity(0.6),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () => controller.sendMessage(prompt),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Messages List
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return AiChatBubble(
                  message: message,
                  onQuestionTap: (question) => controller.sendMessage(question),
                );
              },
            )),
          ),

          // Typing Indicator
          Obx(() {
            if (controller.isTyping.value) {
              return Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    Text('ServiceBot is thinking...', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.strokeColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: controller.inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: controller.sendMessage,
                        decoration: const InputDecoration(
                          hintText: 'Ask about any service or get recommendations...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => controller.sendMessage(controller.inputController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

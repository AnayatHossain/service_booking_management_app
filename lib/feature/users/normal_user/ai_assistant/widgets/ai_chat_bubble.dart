import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import '../model/ai_message_model.dart';
import 'ai_service_card.dart';

class AiChatBubble extends StatelessWidget {
  final AiMessage message;
  final ValueChanged<String>? onQuestionTap;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryColor, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),

          // Suggested Services Cards (if returned by AI)
          if (!isUser && message.suggestedServices.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.suggestedServices.length,
                  itemBuilder: (_, index) => AiServiceCard(service: message.suggestedServices[index]),
                ),
              ),
            ),
          ],

          // Follow-up question chips
          if (!isUser && message.suggestedQuestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.suggestedQuestions.map((q) {
                  return ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 11, color: AppColors.primaryColor)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primaryLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onPressed: () => onQuestionTap?.call(q),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import '../model/ai_message_model.dart';
import 'ai_markdown_text.dart';
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
                  radius: 15,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryColor, size: 17),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AiMarkdownText(
                    text: message.text,
                    isUser: isUser,
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),

          // Suggested Services Cards (if returned by AI)
          if (!isUser && message.suggestedServices.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 38, top: 8),
              child: SizedBox(
                height: 104,
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
              padding: const EdgeInsets.only(left: 38, top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.suggestedQuestions.map((q) {
                  return ActionChip(
                    label: Text(
                      q,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
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

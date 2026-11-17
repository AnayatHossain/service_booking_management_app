import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';

class AiMarkdownText extends StatelessWidget {
  final String text;
  final bool isUser;

  const AiMarkdownText({
    super.key,
    required this.text,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Horizontal separator
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
        );
        continue;
      }

      // Headings (### or ## or #)
      if (trimmed.startsWith('#')) {
        final content = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        final cleanContent = content.replaceAll('**', '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              cleanContent,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet points (* or - or •)
      final bulletMatch = RegExp(r'^(\s*)([\*\-•])\s+(.*)$').firstMatch(line);
      if (bulletMatch != null) {
        final indentLevel = bulletMatch.group(1)?.length ?? 0;
        final bulletText = bulletMatch.group(3) ?? '';
        final leftPadding = (indentLevel > 2) ? 18.0 : 6.0;

        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: leftPadding, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indentLevel > 2 ? '◦ ' : '• ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    height: 1.4,
                  ),
                ),
                Expanded(
                  child: _buildRichText(bulletText),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular line with potential inline bold (**text**)
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _buildRichText(trimmed),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichText(String input) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: input.substring(lastIndex, match.start),
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(TextSpan(
        text: input.substring(lastIndex),
        style: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

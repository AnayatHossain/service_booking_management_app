import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/app_colors.dart';

class EmptyScreenWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? imagePath;

  const EmptyScreenWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
    this.onTap,
    this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final textSubtitle = subTitle ?? subtitle ?? '';
    final buttonAction = onButtonTap ?? onTap;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (textSubtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Subtitle
              Text(
                textSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],

            if (buttonText != null && buttonAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: buttonAction,
                child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

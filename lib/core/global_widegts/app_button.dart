import 'package:flutter/material.dart';
import '../const/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final Color? borderColor;
  final double? textSize;
  final IconData? icon;
  final String? imagePath;
  final bool isLoading;

  const AppButton({
    required this.onTap,
    required this.text,
    this.buttonColor,
    this.textColor,
    this.textSize,
    this.borderColor = Colors.transparent,
    this.icon,
    this.imagePath,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? (buttonColor ?? AppColors.primaryColor)
              : (buttonColor ?? AppColors.primaryColor).withOpacity(0.6),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor ?? Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null) ...[
                Image.asset(
                  imagePath!,
                  height: 20,
                  width: 20,
                  color: textColor ?? Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: (textSize != null && textSize != 0)
                      ? textSize
                      : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: textColor ?? Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../const/app_colors.dart';

class SecondaryAppButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final String? imagePath;

  const SecondaryAppButton({
    required this.onTap,
    required this.text,
    this.buttonColor = Colors.transparent,
    this.textColor = AppColors.whiteColor,
    this.borderColor = AppColors.whiteColor,
    this.icon,
    this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? AppColors.primaryColor),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

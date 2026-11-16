import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/app_colors.dart';

class EmptyScreenWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String buttonText;
  final VoidCallback? onButtonTap;
  final String imagePath;

  const EmptyScreenWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.buttonText,
    this.onButtonTap,
    this.imagePath = "assets/images/empty_screen.png",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 300, height: 300),
            const SizedBox(height: 30),

            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                color: AppColors.blackColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              subTitle,
              style: GoogleFonts.inter(
                color: AppColors.blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Button
            GestureDetector(
              onTap: onButtonTap,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

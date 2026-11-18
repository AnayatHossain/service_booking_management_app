import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';

class RatingReviewDialog extends StatefulWidget {
  final String appointmentId;
  final String serviceName;
  final String? serviceCategory;
  final String? serviceImage;
  final double initialRating;
  final String? initialReview;
  final bool isEdit;
  final Future<void> Function(double rating, String? review) onSubmit;

  const RatingReviewDialog({
    super.key,
    required this.appointmentId,
    required this.serviceName,
    this.serviceCategory,
    this.serviceImage,
    this.initialRating = 5.0,
    this.initialReview,
    this.isEdit = false,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String appointmentId,
    required String serviceName,
    String? serviceCategory,
    String? serviceImage,
    double initialRating = 5.0,
    String? initialReview,
    bool isEdit = false,
    required Future<void> Function(double rating, String? review) onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RatingReviewDialog(
        appointmentId: appointmentId,
        serviceName: serviceName,
        serviceCategory: serviceCategory,
        serviceImage: serviceImage,
        initialRating: initialRating,
        initialReview: initialReview,
        isEdit: isEdit,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<RatingReviewDialog> createState() => _RatingReviewDialogState();
}

class _RatingReviewDialogState extends State<RatingReviewDialog> {
  late double _selectedRating;
  late final TextEditingController _reviewController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
    _reviewController = TextEditingController(text: widget.initialReview ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    if (_selectedRating >= 5.0) return 'Exceptional Experience! 🌟';
    if (_selectedRating >= 4.0) return 'Very Good Service! 👍';
    if (_selectedRating >= 3.0) return 'Satisfactory Experience 🙂';
    if (_selectedRating >= 2.0) return 'Needs Improvement ⚠️';
    return 'Unsatisfactory 😞';
  }

  Color get _ratingBadgeColor {
    if (_selectedRating >= 4.5) return const Color(0xFF059669);
    if (_selectedRating >= 4.0) return const Color(0xFF2563EB);
    if (_selectedRating >= 3.0) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final reviewText = _reviewController.text.trim();
      await widget.onSubmit(
        _selectedRating,
        reviewText.isNotEmpty ? reviewText : null,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 32),
                  // Glowing Gold Badge
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFD97706),
                        size: 34,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Headline
              Text(
                widget.isEdit ? 'Edit Service Review' : 'Rate & Review Service',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // Contextual Service Pill with Original Service Photo
              Container(
                padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.serviceImage != null && widget.serviceImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.serviceImage!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 24,
                            height: 24,
                            color: const Color(0xFFE2E8F0),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 24,
                            height: 24,
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(
                              Icons.home_repair_service_rounded,
                              size: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive 5-Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  final isFilled = starVal <= _selectedRating;
                  return GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () {
                            setState(() => _selectedRating = starVal);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedScale(
                        scale: isFilled ? 1.08 : 0.95,
                        duration: const Duration(milliseconds: 160),
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 38,
                          color: isFilled
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Dynamic Sentiment Chip
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _ratingBadgeColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _ratingLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _ratingBadgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Feedback Textarea
              TextField(
                controller: _reviewController,
                maxLines: 3,
                maxLength: 300,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts, compliments, or suggestions...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  counterStyle: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.6),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),

              // Industry-Grade Action Buttons
              Row(
                children: [
                  // Cancel / Maybe Later Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Submit Review Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              :  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      widget.isEdit ? 'Update Review' : 'Submit Review',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

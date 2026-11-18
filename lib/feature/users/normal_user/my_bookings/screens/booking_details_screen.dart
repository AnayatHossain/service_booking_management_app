import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/core/global_widegts/app_button.dart';
import 'package:service_booking_management_app/core/global_widegts/delete_review_dialog.dart';
import 'package:service_booking_management_app/core/global_widegts/rating_review_dialog.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../model/booking_model.dart';
import '../widgets/booking_status_chip.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onCancelBooking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.onCancelBooking,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;
  late BookingModel _booking;
  StreamSubscription? _ratedSub;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _ratedSub = BookingEventBus.ratedStream.listen((event) {
      if (event.bookingId == _booking.id && mounted) {
        setState(() {
          if (event.isDeleted) {
            _booking = _booking.copyWithRatingReset();
          } else {
            _booking = _booking.copyWith(
              isRated: true,
              rating: event.rating,
              review: event.review,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ratedSub?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      _refreshController.refreshCompleted();
    }
  }

  void _handleRateOrEditReview(bool isEdit) {
    RatingReviewDialog.show(
      context,
      appointmentId: _booking.id,
      serviceName: _booking.serviceName,
      serviceCategory: _booking.serviceCategory,
      serviceImage: _booking.serviceImage,
      initialRating: _booking.rating ?? 5.0,
      initialReview: _booking.review,
      isEdit: isEdit,
      onSubmit: (rating, review) async {
        final token = await Urls.rawToken;
        final api = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.rateAppointment(_booking.id),
          apiType: isEdit ? ApiType.put : ApiType.post,
          apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
          apiBody: ApiBody.json({
            'rating': rating,
            if (review != null) 'review': review,
          }),
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );

        final res = await api.call();
        if (res.isSuccess) {
          if (mounted) {
            setState(() {
              _booking = _booking.copyWith(
                isRated: true,
                rating: rating,
                review: review,
              );
            });
          }
          BookingEventBus.notifyBookingRated(
            bookingId: _booking.id,
            rating: rating,
            review: review,
          );
          Get.snackbar(
            'Success',
            isEdit ? 'Your review has been updated! ⭐' : 'Thank you for your rating! ⭐',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE8F5E9),
            colorText: const Color(0xFF1B5E20),
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
            margin: const EdgeInsets.all(16),
            borderRadius: 14,
          );
        } else {
          Get.snackbar(
            'Error',
            res.errorMessage ?? 'Failed to submit rating.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFEBEE),
            colorText: const Color(0xFFB71C1C),
            icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
            margin: const EdgeInsets.all(16),
            borderRadius: 14,
          );
        }
      },
    );
  }

  void _handleDeleteReview() async {
    final confirmed = await DeleteReviewDialog.show(
      context,
      serviceName: _booking.serviceName,
    );

    if (confirmed == true && mounted) {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.rateAppointment(_booking.id),
        apiType: ApiType.delete,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final res = await api.call();
      if (res.isSuccess) {
        if (mounted) {
          setState(() {
            _booking = _booking.copyWithRatingReset();
          });
        }
        BookingEventBus.notifyBookingRatingDeleted(bookingId: _booking.id);
        Get.snackbar(
          'Removed',
          'Your rating & review have been deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF2F2),
          colorText: const Color(0xFF991B1B),
          icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFDC2626)),
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      } else {
        Get.snackbar(
          'Error',
          res.errorMessage ?? 'Failed to delete review.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFB71C1C),
          icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppSvgIcons.backArrow,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(
          waterDropColor: AppColors.primaryColor,
          complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Refreshed',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        onRefresh: _onRefresh,
        child: Skeletonizer(
          enabled: _isLoading,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status & Booking ID Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Reference',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '#${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: booking.id));
                                      Get.snackbar(
                                        'Copied',
                                        'Booking ID copied to clipboard',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.white,
                                      );
                                    },
                                    child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          BookingStatusChip(status: booking.status),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.strokeColor),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppSvgIcons.calendar,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date & Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text(
                                  '${booking.date} at ${booking.timeSlot}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Service Summary Card
                const Text(
                  'Service Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          booking.serviceImage,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.serviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.serviceCategory} • ${booking.durationMinutes} mins',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${booking.servicePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Customer Notes (if provided)
                if (booking.customerNotes != null && booking.customerNotes!.isNotEmpty) ...[
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                    ),
                    child: Text(
                      booking.customerNotes!,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 4. Payment & Price Breakdown
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Service Fee', '\$${booking.servicePrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Booking & Admin Fee', '\$0.00'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Estimated Tax', '\$0.00'),
                      const Divider(height: 20, color: AppColors.strokeColor),
                      _buildReceiptRow(
                        'Total Payable',
                        '\$${booking.servicePrice.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                if (booking.isCompleted) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Review & Feedback',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      if (booking.isAlreadyRated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text(
                                'Verified Client Review',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: booking.isAlreadyRated
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Amber Rating Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(booking.rating ?? 5.0).toStringAsFixed(1)} / 5.0 Rating',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  // Edit Button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _handleRateOrEditReview(true),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppSvgIcons.edit,
                                              width: 12,
                                              height: 12,
                                              colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete Button with SVG
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _handleDeleteReview,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFFECDD3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppSvgIcons.delete,
                                              width: 12,
                                              height: 12,
                                              colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFDC2626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // 5 Star visual display
                              Row(
                                children: List.generate(5, (index) {
                                  final starVal = index + 1.0;
                                  final isFilled = starVal <= (booking.rating ?? 5.0);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Icon(
                                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 20,
                                      color: isFilled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                    ),
                                  );
                                }),
                              ),
                              if (booking.review != null && booking.review!.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: const Border(
                                      left: BorderSide(color: Color(0xFFF59E0B), width: 3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.format_quote_rounded, size: 14, color: Color(0xFF94A3B8)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Your Feedback',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        booking.review!.trim(),
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E293B),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'You haven\'t rated this service yet. Share your experience to help the service provider improve!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                ),
                                onPressed: () => _handleRateOrEditReview(false),
                                icon: const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFDE68A)),
                                label: const Text(
                                  'Rate & Review Service',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 5. Cancel Booking Action
                if (booking.canBeCancelled && widget.onCancelBooking != null)
                  AppButton(
                    text: 'Cancel Appointment',
                    buttonColor: AppColors.error,
                    onTap: widget.onCancelBooking,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? AppColors.primaryColor : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

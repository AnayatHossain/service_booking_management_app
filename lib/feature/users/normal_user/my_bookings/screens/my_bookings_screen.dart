import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/empty_screen_widget.dart';
import 'package:service_booking_management_app/core/global_widegts/rating_review_dialog.dart';
import '../bloc/my_bookings_bloc.dart';
import '../bloc/my_bookings_event.dart';
import '../bloc/my_bookings_state.dart';
import '../model/booking_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_filter_tabs.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _confirmCancel(BuildContext context, BookingModel booking, MyBookingsBloc bloc) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 20,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Layered Double-Ring Glowing Destructive Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF2F2),
                  border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFEE2E2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event_busy_rounded,
                        color: Color(0xFFDC2626),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Centered Headline
              const Text(
                'Cancel Appointment?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // 3. Subtitle / Guidance
              const Text(
                'Are you sure? This booking will be removed from your schedule and cannot be recovered.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // 4. Contextual Booking Summary Capsule
              Container(
                margin: const EdgeInsets.only(top: 18, bottom: 22),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        booking.serviceImage,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.cleaning_services_rounded,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.date} • ${booking.timeSlot}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${booking.servicePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Full-Width Balanced Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
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
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Keep Booking',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withOpacity(0.35),
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
                          onPressed: () {
                            Navigator.pop(ctx);
                            bloc.add(MyBookingsCancelRequested(booking.id));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Yes, Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
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

  void _showRatingDialog(BuildContext context, BookingModel booking, MyBookingsBloc bloc) {
    RatingReviewDialog.show(
      context,
      appointmentId: booking.id,
      serviceName: booking.serviceName,
      serviceCategory: booking.serviceCategory,
      serviceImage: booking.serviceImage,
      onSubmit: (rating, review) async {
        bloc.add(MyBookingsRateRequested(
          appointmentId: booking.id,
          rating: rating,
          review: review,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBookingsBloc(),
      child: BlocConsumer<MyBookingsBloc, MyBookingsState>(
        listener: (context, state) {
          if (state.status == MyBookingsStatus.success || state.status == MyBookingsStatus.failure) {
            _refreshController.refreshCompleted();
          }
          if (state.successMessage != null) {
            Get.snackbar(
              'Success',
              state.successMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE8F5E9),
              colorText: const Color(0xFF1B5E20),
              icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
              margin: const EdgeInsets.all(16),
              borderRadius: 14,
            );
          } else if (state.errorMessage != null) {
            Get.snackbar(
              'Error',
              state.errorMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFFFEBEE),
              colorText: const Color(0xFFB71C1C),
              icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
              margin: const EdgeInsets.all(16),
              borderRadius: 14,
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<MyBookingsBloc>();
          final isLoading = state.status == MyBookingsStatus.loading && state.allBookings.isEmpty;

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'My Appointments',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: BookingFilterTabs(
                  selectedIndex: state.selectedTab,
                  onTabSelected: (idx) {
                    _refreshController.refreshCompleted();
                    bloc.add(MyBookingsFilterChanged(idx));
                  },
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
              onRefresh: () {
                bloc.add(const MyBookingsFetchRequested());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 145),
                children: [
                  Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          ...List.generate(
                            3,
                            (index) => BookingCard(
                              booking: BookingModel(
                                id: 'placeholder-$index',
                                userId: 'uid',
                                userName: 'Customer Name',
                                userEmail: 'user@example.com',
                                serviceId: 'sid',
                                serviceName: 'Loading Appointment Details...',
                                serviceCategory: 'Home Care',
                                servicePrice: 45.0,
                                serviceImage: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
                                date: '2026-11-20',
                                timeSlot: '10:00 AM',
                                durationMinutes: 60,
                                status: 'Confirmed',
                                createdAt: '',
                              ),
                              onCancelTap: null,
                            ),
                          )
                        else if (state.filteredBookings.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: EmptyScreenWidget(
                              title: 'No Appointments Found',
                              subtitle: state.selectedTab == 0
                                  ? 'You have not booked any appointments yet.'
                                  : 'No appointments under this status.',
                              icon: Icons.event_busy_rounded,
                            ),
                          )
                        else
                          ...state.filteredBookings.map(
                            (booking) => BookingCard(
                              booking: booking,
                              onTap: () {
                                Get.to(() => BookingDetailsScreen(
                                      booking: booking,
                                      onCancelBooking: booking.canBeCancelled
                                          ? () => _confirmCancel(context, booking, bloc)
                                          : null,
                                    ));
                              },
                              onCancel: booking.canBeCancelled
                                  ? () => _confirmCancel(context, booking, bloc)
                                  : null,
                              onRateTap: booking.canBeRated
                                  ? () => _showRatingDialog(context, booking, bloc)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

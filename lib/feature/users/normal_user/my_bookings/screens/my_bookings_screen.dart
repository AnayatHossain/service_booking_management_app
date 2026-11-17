import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/empty_screen_widget.dart';
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel your appointment for "${booking.serviceName}" on ${booking.date} at ${booking.timeSlot}?',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(MyBookingsCancelRequested(booking.id));
            },
            child: const Text('Confirm Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, BookingModel booking, MyBookingsBloc bloc) {
    double selectedRating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          String ratingLabel;
          if (selectedRating >= 5.0) {
            ratingLabel = 'Excellent! 🌟';
          } else if (selectedRating >= 4.0) {
            ratingLabel = 'Very Good! 😊';
          } else if (selectedRating >= 3.0) {
            ratingLabel = 'Good 🙂';
          } else if (selectedRating >= 2.0) {
            ratingLabel = 'Fair 😐';
          } else {
            ratingLabel = 'Needs Improvement 😕';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFBEB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate & Review Service',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.serviceName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Interactive Star Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starValue <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 38,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ratingLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Review Text Field
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Share your experience (optional)...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.strokeColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.strokeColor.withOpacity(0.8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Not Now', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  bloc.add(MyBookingsRateRequested(
                    appointmentId: booking.id,
                    rating: selectedRating,
                    review: reviewController.text.trim().isNotEmpty ? reviewController.text.trim() : null,
                  ));
                },
                child: const Text('Submit Rating', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
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
              child: Skeletonizer(
                enabled: isLoading,
                child: (!isLoading && state.filteredBookings.isEmpty)
                    ? EmptyScreenWidget(
                        title: 'No Appointments Found',
                        subtitle: state.selectedTab == 0
                            ? 'You have not booked any appointments yet.'
                            : 'No appointments under this status.',
                        icon: Icons.event_busy_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 28),
                        itemCount: isLoading ? 3 : state.filteredBookings.length,
                        itemBuilder: (context, index) {
                          if (isLoading) {
                            return BookingCard(
                              booking: BookingModel(
                                id: 'placeholder-id',
                                userId: 'uid',
                                userName: 'User Name',
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
                            );
                          }

                          final booking = state.filteredBookings[index];
                          return BookingCard(
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
                          );
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

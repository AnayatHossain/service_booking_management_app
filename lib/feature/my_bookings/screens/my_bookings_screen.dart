import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/empty_screen_widget.dart';
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

  void _confirmCancel(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to cancel your appointment for "${booking.serviceName}" on ${booking.date}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Appointment', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MyBookingsBloc>().add(MyBookingsCancelRequested(booking.id));
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
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
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
          } else if (state.errorMessage != null) {
            Get.snackbar(
              'Error',
              state.errorMessage!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
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
              centerTitle: false,
              title: const Text(
                'My Appointments',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
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
                        title: 'No Bookings Found',
                        subtitle: state.selectedTab == 0
                            ? 'You have not booked any appointments yet.'
                            : 'No appointments in this category.',
                        icon: Icons.event_busy_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 24),
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
                                serviceName: 'Loading Service Name Here...',
                                serviceCategory: 'Cleaning',
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
                                        ? () => _confirmCancel(context, booking)
                                        : null,
                                  ));
                            },
                            onCancel: booking.canBeCancelled ? () => _confirmCancel(context, booking) : null,
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

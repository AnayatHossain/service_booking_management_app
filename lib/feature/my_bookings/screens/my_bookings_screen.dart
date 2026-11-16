import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/empty_screen_widget.dart';
import '../bloc/my_bookings_bloc.dart';
import '../bloc/my_bookings_event.dart';
import '../bloc/my_bookings_state.dart';
import '../model/booking_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_filter_tabs.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

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
                    context.read<MyBookingsBloc>().add(MyBookingsFilterChanged(idx));
                  },
                ),
              ),
            ),
            body: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async {
                context.read<MyBookingsBloc>().add(const MyBookingsFetchRequested());
              },
              child: state.status == MyBookingsStatus.loading && state.allBookings.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : state.filteredBookings.isEmpty
                      ? EmptyScreenWidget(
                          title: 'No Bookings Found',
                          subtitle: state.selectedTab == 0
                              ? 'You have not booked any appointments yet.'
                              : 'No appointments in this category.',
                          icon: Icons.event_busy_rounded,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 24),
                          itemCount: state.filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = state.filteredBookings[index];
                            return BookingCard(
                              booking: booking,
                              onCancel: booking.canBeCancelled ? () => _confirmCancel(context, booking) : null,
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}

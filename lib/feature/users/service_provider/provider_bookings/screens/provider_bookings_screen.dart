import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/core/global_widegts/empty_screen_widget.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/model/booking_model.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/widgets/booking_filter_tabs.dart';
import '../bloc/provider_bookings_bloc.dart';
import '../bloc/provider_bookings_event.dart';
import '../bloc/provider_bookings_state.dart';
import '../controllers/provider_bookings_controller.dart';
import '../widgets/provider_booking_card.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  static final List<BookingModel> _dummyBookings = List.generate(
    3,
    (i) => BookingModel(
      id: 'dummy_$i',
      userId: 'uid',
      userName: 'Alex Johnson',
      userEmail: 'user@example.com',
      serviceId: 'srv_$i',
      serviceName: 'Full House Deep Cleaning',
      serviceCategory: 'Home Cleaning',
      servicePrice: 120.0,
      serviceImage: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      date: '2026-11-21',
      timeSlot: '04:30 PM',
      durationMinutes: 180,
      status: 'Pending',
      customerNotes: 'Please focus on the kitchen and bathrooms.',
      createdAt: '2026-11-18',
    ),
  );

  StreamSubscription<BookingStatusEvent>? _eventSub;
  StreamSubscription<BookingRatedEvent>? _ratedSub;

  @override
  void dispose() {
    _eventSub?.cancel();
    _ratedSub?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ProviderBookingsBloc()..add(const ProviderBookingsFetchRequested());
        _eventSub = BookingEventBus.stream.listen((event) {
          bloc.add(const ProviderBookingsFetchRequested(silent: true));
        });
        _ratedSub = BookingEventBus.ratedStream.listen((event) {
          bloc.add(const ProviderBookingsFetchRequested(silent: true));
        });
        return bloc;
      },
      child: BlocConsumer<ProviderBookingsBloc, ProviderBookingsState>(
        listener: (context, state) {
          if (state.status == ProviderBookingsStatus.success ||
              state.status == ProviderBookingsStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProviderBookingsStatus.loading;
          final list = state.allBookings.isNotEmpty
              ? state.filteredBookings
              : (isLoading ? _dummyBookings : <BookingModel>[]);

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Bookings Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: BookingFilterTabs(
                  selectedIndex: state.selectedTab,
                  onTabSelected: (idx) {
                    context.read<ProviderBookingsBloc>().add(ProviderBookingsTabChanged(idx));
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
                context.read<ProviderBookingsBloc>().add(const ProviderBookingsFetchRequested());
              },
              child: Skeletonizer(
                enabled: isLoading && state.allBookings.isEmpty,
                child: (!isLoading && list.isEmpty)
                    ? EmptyScreenWidget(
                        title: 'No Appointments Found',
                        subtitle: state.selectedTab == 0
                            ? 'No appointments received from clients yet.'
                            : 'No appointments under ${ProviderBookingsState.tabs[state.selectedTab]} status.',
                        icon: Icons.event_busy_rounded,
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 145),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final booking = list[idx];
                          return ProviderBookingCard(
                            booking: booking,
                            onTap: () {
                              ProviderBookingsController.navigateToDetails(
                                context,
                                booking,
                                onStatusChanged: () {
                                  context.read<ProviderBookingsBloc>().add(const ProviderBookingsFetchRequested());
                                },
                              );
                            },
                            onConfirm: () {
                              ProviderBookingsController.showConfirmDialog(
                                context,
                                booking: booking,
                                onConfirm: () {
                                  context.read<ProviderBookingsBloc>().add(
                                        ProviderBookingStatusUpdateRequested(
                                          bookingId: booking.id,
                                          newStatus: 'Confirmed',
                                        ),
                                      );
                                },
                              );
                            },
                            onDecline: () {
                              ProviderBookingsController.showDeclineDialog(
                                context,
                                booking: booking,
                                onDecline: () {
                                  context.read<ProviderBookingsBloc>().add(
                                        ProviderBookingStatusUpdateRequested(
                                          bookingId: booking.id,
                                          newStatus: 'Cancelled',
                                        ),
                                      );
                                },
                              );
                            },
                            onComplete: () {
                              ProviderBookingsController.showCompleteDialog(
                                context,
                                booking: booking,
                                onComplete: () {
                                  context.read<ProviderBookingsBloc>().add(
                                        ProviderBookingStatusUpdateRequested(
                                          bookingId: booking.id,
                                          newStatus: 'Completed',
                                        ),
                                      );
                                },
                              );
                            },
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

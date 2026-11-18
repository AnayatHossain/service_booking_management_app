import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/model/booking_model.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/bloc/provider_bookings_bloc.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/bloc/provider_bookings_event.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/controllers/provider_bookings_controller.dart';
import '../bloc/provider_dashboard_bloc.dart';
import '../bloc/provider_dashboard_event.dart';
import '../bloc/provider_dashboard_state.dart';
import '../controllers/provider_dashboard_controller.dart';
import '../widgets/provider_dashboard_metric_card.dart';
import '../widgets/provider_recent_appointment_tile.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const ProviderDashboardScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  StreamSubscription<BookingStatusEvent>? _eventSub;
  StreamSubscription<BookingRatedEvent>? _ratedSub;

  static final List<Map<String, dynamic>> _dummyBookings = [
    {
      'id': 'dummy_1',
      'service_name': 'Full House Deep Cleaning',
      'user_name': 'Alex Johnson',
      'date': '2026-11-21',
      'time_slot': '04:30 PM',
      'status': 'Pending',
      'service_image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
    },
    {
      'id': 'dummy_2',
      'service_name': 'Car Wash & Ceramic Paint Detailing',
      'user_name': 'Sarah Williams',
      'date': '2026-11-22',
      'time_slot': '10:00 AM',
      'status': 'Pending',
      'service_image': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800',
    },
  ];

  @override
  void dispose() {
    _eventSub?.cancel();
    _ratedSub?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  BookingModel _mapToBookingModel(Map<String, dynamic> b) {
    return BookingModel(
      id: (b['id'] ?? b['_id'] ?? '').toString(),
      userId: (b['user_id'] ?? '').toString(),
      userName: (b['user_name'] ?? 'Client').toString(),
      userEmail: (b['user_email'] ?? '').toString(),
      serviceId: (b['service_id'] ?? '').toString(),
      serviceName: (b['service_name'] ?? 'Service').toString(),
      serviceCategory: (b['service_category'] ?? 'General').toString(),
      servicePrice: double.tryParse((b['service_price'] ?? 0).toString()) ?? 0.0,
      serviceImage: (b['service_image'] ?? '').toString(),
      date: (b['date'] ?? '').toString(),
      timeSlot: (b['time_slot'] ?? '').toString(),
      durationMinutes: int.tryParse((b['duration_minutes'] ?? 60).toString()) ?? 60,
      status: (b['status'] ?? 'Pending').toString(),
      customerNotes: b['customer_notes']?.toString(),
      createdAt: (b['created_at'] ?? '').toString(),
      isRated: b['is_rated'] == true || b['rating'] != null,
      rating: double.tryParse((b['rating'] ?? '').toString()),
      review: b['review']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final bloc = ProviderDashboardBloc()..add(const ProviderDashboardFetchRequested());
            _eventSub = BookingEventBus.stream.listen((event) {
              bloc.add(ProviderDashboardBookingStatusUpdated(
                bookingId: event.bookingId,
                newStatus: event.newStatus,
              ));
            });
            _ratedSub = BookingEventBus.ratedStream.listen((event) {
              bloc.add(const ProviderDashboardFetchRequested(silent: true));
            });
            return bloc;
          },
        ),
        BlocProvider(create: (context) => ProviderBookingsBloc()),
      ],
      child: BlocConsumer<ProviderDashboardBloc, ProviderDashboardState>(
        listener: (context, state) {
          if (state.status == ProviderDashboardStatus.success ||
              state.status == ProviderDashboardStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProviderDashboardStatus.loading;
          final d = state.dashboardData;
          final recentList = d.recentBookings.isNotEmpty ? d.recentBookings : (isLoading ? _dummyBookings : []);

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SafeArea(
              child: SmartRefresher(
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
                  context.read<ProviderDashboardBloc>().add(const ProviderDashboardFetchRequested());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Profile Bar
                      _buildHeader(context, d),
                      const SizedBox(height: 18),

                      // Metric Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: ProviderDashboardMetricCard(
                              label: 'Services',
                              value: '${d.totalServices}',
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProviderDashboardMetricCard(
                              label: 'Bookings',
                              value: '${d.totalBookings}',
                              icon: Icons.calendar_month_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              bgColor: const Color(0xFFF5F3FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProviderDashboardMetricCard(
                              label: 'Pending',
                              value: '${d.pendingBookings}',
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              bgColor: const Color(0xFFFFFBEB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProviderDashboardMetricCard(
                              label: 'Done',
                              value: '${d.completedBookings}',
                              icon: Icons.task_alt_rounded,
                              iconColor: const Color(0xFF10B981),
                              bgColor: const Color(0xFFECFDF5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section Header: Recent Appointments
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Appointments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${recentList.length} total',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recent Appointments List
                      Skeletonizer(
                        enabled: isLoading && d.recentBookings.isEmpty,
                        child: recentList.isEmpty && !isLoading
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.event_available_rounded, size: 44, color: Color(0xFF94A3B8)),
                                    SizedBox(height: 10),
                                    Text(
                                      'No Appointments Yet',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'New client bookings will appear here in real-time.',
                                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentList.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, idx) {
                                  final bookingMap = Map<String, dynamic>.from(recentList[idx] as Map);
                                  final bookingObj = _mapToBookingModel(bookingMap);
                                  return ProviderRecentAppointmentTile(
                                    booking: bookingMap,
                                    onTap: () {
                                      ProviderDashboardController.navigateToBookingDetails(
                                        context,
                                        bookingObj,
                                        onStatusChanged: () {
                                          context.read<ProviderDashboardBloc>().add(const ProviderDashboardFetchRequested());
                                        },
                                      );
                                    },
                                    onConfirm: () {
                                      ProviderBookingsController.showConfirmDialog(
                                        context,
                                        booking: bookingObj,
                                        onConfirm: () {
                                          context.read<ProviderBookingsBloc>().add(
                                                ProviderBookingStatusUpdateRequested(
                                                  bookingId: bookingObj.id,
                                                  newStatus: 'Confirmed',
                                                ),
                                              );
                                          context.read<ProviderDashboardBloc>().add(
                                                ProviderDashboardBookingStatusUpdated(
                                                  bookingId: bookingObj.id,
                                                  newStatus: 'Confirmed',
                                                ),
                                              );
                                        },
                                      );
                                    },
                                    onDecline: () {
                                      ProviderBookingsController.showDeclineDialog(
                                        context,
                                        booking: bookingObj,
                                        onDecline: () {
                                          context.read<ProviderBookingsBloc>().add(
                                                ProviderBookingStatusUpdateRequested(
                                                  bookingId: bookingObj.id,
                                                  newStatus: 'Cancelled',
                                                ),
                                              );
                                          context.read<ProviderDashboardBloc>().add(
                                                ProviderDashboardBookingStatusUpdated(
                                                  bookingId: bookingObj.id,
                                                  newStatus: 'Cancelled',
                                                ),
                                              );
                                        },
                                      );
                                    },
                                    onComplete: () {
                                      ProviderBookingsController.showCompleteDialog(
                                        context,
                                        booking: bookingObj,
                                        onComplete: () {
                                          context.read<ProviderBookingsBloc>().add(
                                                ProviderBookingStatusUpdateRequested(
                                                  bookingId: bookingObj.id,
                                                  newStatus: 'Completed',
                                                ),
                                              );
                                          context.read<ProviderDashboardBloc>().add(
                                                ProviderDashboardBookingStatusUpdated(
                                                  bookingId: bookingObj.id,
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic d) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 1.5),
                ),
                child: ClipOval(
                  child: d.avatarUrl != null && d.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: d.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _buildInitialsAvatar(d.providerName),
                          errorWidget: (_, __, ___) => _buildInitialsAvatar(d.providerName),
                        )
                      : _buildInitialsAvatar(d.providerName),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.providerName,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (d.institutionName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  d.institutionName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // Notification Bell Icon with Badge
        GestureDetector(
          onTap: () {
            ProviderDashboardController.navigateToNotifications(
              context,
              onBack: () {
                context.read<ProviderDashboardBloc>().add(const ProviderDashboardFetchRequested(silent: true));
              },
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.strokeColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: SvgPicture.asset(
                    AppSvgIcons.notification,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                  ),
                ),
                if (d.unreadCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: d.unreadCount > 9 ? 4.5 : 3,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          d.unreadCount > 99 ? '99+' : '${d.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

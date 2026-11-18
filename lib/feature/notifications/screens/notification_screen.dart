import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/core/global_widegts/empty_screen_widget.dart';
import 'package:service_booking_management_app/core/global_widegts/rating_review_dialog.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/model/service_model.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/model/booking_model.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/screens/booking_details_screen.dart';
import 'package:service_booking_management_app/feature/users/normal_user/service_details/screens/service_details_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/screens/provider_appointment_details_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/widgets/provider_appointment_dialogs.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  final bool? isProvider;
  const NotificationScreen({super.key, this.isProvider});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isProvider = false;

  final List<NotificationModel> _fallbackProviderNotifications = [
    NotificationModel(
      id: 'apt_notif_1',
      title: 'New Appointment Booking',
      message: 'Alex Johnson has booked Car Wash & Ceramic Paint Detailing for 2026-11-21 at 04:30 PM.',
      type: 'booking',
      appointmentId: 'apt_1',
      serviceName: 'Car Wash & Ceramic Paint Detailing',
      serviceImage: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800',
      servicePrice: 75.0,
      clientName: 'Alex Johnson',
      date: '2026-11-21',
      timeSlot: '04:30 PM',
      status: 'Pending',
      isRead: false,
      createdAt: '2026-11-18T00:30:00Z',
    ),
    NotificationModel(
      id: 'apt_notif_2',
      title: 'New Appointment Booking',
      message: 'Alex Johnson has booked Luxury Aromatherapy Spa & Massage for 2026-11-22 at 06:00 PM.',
      type: 'booking',
      appointmentId: 'apt_2',
      serviceName: 'Luxury Aromatherapy Spa & Massage',
      serviceImage: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
      servicePrice: 85.0,
      clientName: 'Alex Johnson',
      date: '2026-11-22',
      timeSlot: '06:00 PM',
      status: 'Pending',
      isRead: false,
      createdAt: '2026-11-18T01:00:00Z',
    ),
    NotificationModel(
      id: 'apt_notif_3',
      title: 'New Appointment Booking',
      message: 'Alex Johnson booked Air Conditioner Master Service on 2026-11-19 at 05:00 PM.',
      type: 'booking',
      appointmentId: 'apt_3',
      serviceName: 'Air Conditioner Master Service',
      serviceImage: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      servicePrice: 95.0,
      clientName: 'Alex Johnson',
      date: '2026-11-19',
      timeSlot: '05:00 PM',
      status: 'Confirmed',
      isRead: true,
      createdAt: '2026-11-17T20:00:00Z',
    ),
    NotificationModel(
      id: 'apt_notif_4',
      title: 'Appointment Cancelled by Client',
      message: 'Alex Johnson has cancelled their appointment for Executive Haircut & Beard Styling on 2026-11-20 at 10:00 AM.',
      type: 'booking',
      appointmentId: 'apt_4',
      serviceName: 'Executive Haircut & Beard Styling',
      serviceImage: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      servicePrice: 45.0,
      clientName: 'Alex Johnson',
      date: '2026-11-20',
      timeSlot: '10:00 AM',
      status: 'Cancelled',
      isRead: true,
      createdAt: '2026-11-17T18:00:00Z',
    ),
    NotificationModel(
      id: 'apt_notif_5',
      title: 'New Client Rating',
      message: 'Alex Johnson gave 5.0★ rating for Air Conditioner Master Service: "Outstanding service and prompt response!"',
      type: 'review',
      appointmentId: 'apt_3',
      serviceName: 'Air Conditioner Master Service',
      serviceImage: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      servicePrice: 95.0,
      clientName: 'Alex Johnson',
      date: '2026-11-19',
      timeSlot: '05:00 PM',
      status: 'Completed',
      rating: 5.0,
      isRead: true,
      createdAt: '2026-11-17T21:00:00Z',
    ),
  ];

  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  StreamSubscription<BookingStatusEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _isProvider = widget.isProvider ?? false;
    _loadUserRole();
    _eventSub = BookingEventBus.stream.listen((event) {
      if (!mounted) return;
      setState(() {
        final idx = _fallbackProviderNotifications.indexWhere((n) => n.appointmentId == event.bookingId || n.id == event.bookingId);
        if (idx != -1) {
          final cur = _fallbackProviderNotifications[idx];
          _fallbackProviderNotifications[idx] = cur.copyWith(
            status: event.newStatus,
          );
        }
      });
      context.read<NotificationBloc>().add(const NotificationFetchRequested());
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPreferencesHelper.getUserRole();
    final isProv = widget.isProvider ?? (role != null && (role.toLowerCase() == 'provider' || role.toLowerCase() == 'service_provider' || role.toLowerCase().contains('provider')));
    if (mounted) {
      setState(() {
        _isProvider = isProv;
      });
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.calendar_month_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return AppColors.primaryColor;
      case 'review':
        return const Color(0xFFF59E0B);
      case 'promo':
        return Colors.deepOrange;
      case 'reminder':
        return Colors.teal;
      default:
        return AppColors.accentColor;
    }
  }

  // --- Provider Inline Action Handlers ---
  Future<void> _updateBookingStatusAsProvider(
    BuildContext context,
    NotificationModel item,
    String newStatus,
  ) async {
    final appointmentId = item.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) return;

    // Optimistic UI update for immediate feedback
    final fallbackIdx = _fallbackProviderNotifications.indexWhere((n) => n.id == item.id || n.appointmentId == item.appointmentId);
    if (fallbackIdx != -1) {
      setState(() {
        final cur = _fallbackProviderNotifications[fallbackIdx];
        _fallbackProviderNotifications[fallbackIdx] = cur.copyWith(
          status: newStatus,
        );
      });
    }

    // Broadcast globally to Dashboard, Bookings tab, and Details screens
    BookingEventBus.notifyStatusChanged(bookingId: appointmentId, newStatus: newStatus);

    final token = await Urls.bearerToken;
    final api = FlutterApiCraft(
      baseUrl: Urls.baseUrl,
      path: Urls.providerUpdateBookingStatus(appointmentId, newStatus),
      apiType: ApiType.patch,
      apiHeaders: {'Authorization': token},
      enableLoading: true,
      enableApiSuccessResponseGetSnackBar: true,
      enableApiErrorResponseGetSnackBar: true,
    );

    final res = await api.call();
    if (res.isSuccess) {
      if (context.mounted) {
        context.read<NotificationBloc>().add(const NotificationFetchRequested());
      }
    }
  }

  void _showProviderConfirmDialog(BuildContext context, NotificationModel item) {
    ProviderAppointmentDialogs.showConfirmDialog(
      context,
      serviceName: item.serviceName ?? item.title,
      serviceImage: item.serviceImage ?? '',
      clientName: item.clientName ?? 'Client',
      date: item.date ?? '',
      timeSlot: item.timeSlot ?? '',
      price: item.servicePrice ?? 0.0,
      onConfirm: () => _updateBookingStatusAsProvider(context, item, 'Confirmed'),
    );
  }

  void _showProviderDeclineDialog(BuildContext context, NotificationModel item) {
    ProviderAppointmentDialogs.showDeclineDialog(
      context,
      serviceName: item.serviceName ?? item.title,
      serviceImage: item.serviceImage ?? '',
      clientName: item.clientName ?? 'Client',
      date: item.date ?? '',
      timeSlot: item.timeSlot ?? '',
      price: item.servicePrice ?? 0.0,
      onDecline: () => _updateBookingStatusAsProvider(context, item, 'Cancelled'),
    );
  }

  // --- Customer Rating Modal Handler ---
  void _showCustomerRatingDialog(BuildContext context, NotificationModel item) {
    final appointmentId = item.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) return;

    RatingReviewDialog.show(
      context,
      appointmentId: appointmentId,
      serviceName: item.serviceName ?? item.title,
      serviceImage: item.serviceImage,
      onSubmit: (rating, review) async {
        final token = await Urls.bearerToken;
        final api = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.rateAppointment(appointmentId),
          apiType: ApiType.post,
          apiHeaders: {'Authorization': token},
          apiBody: ApiBody.json({
            'rating': rating,
            if (review != null && review.isNotEmpty) 'review': review,
          }),
          enableLoading: true,
          enableApiSuccessResponseGetSnackBar: true,
          enableApiErrorResponseGetSnackBar: true,
        );
        final res = await api.call();
        if (res.isSuccess) {
          BookingEventBus.notifyBookingRated(
            bookingId: appointmentId,
            rating: rating,
            review: review,
          );
          if (context.mounted) {
            context.read<NotificationBloc>().add(const NotificationFetchRequested());
          }
        }
      },
    );
  }

  // --- Deep Link Navigation on Card Tap ---
  void _handleDeepLink(BuildContext context, NotificationModel item) {
    if (item.appointmentId != null && item.appointmentId!.isNotEmpty) {
      final booking = BookingModel(
        id: item.appointmentId!,
        userId: '',
        userName: item.clientName ?? 'Client',
        userEmail: '',
        serviceId: item.serviceId ?? '',
        serviceName: item.serviceName ?? item.title,
        serviceCategory: '',
        servicePrice: item.servicePrice ?? 0.0,
        serviceImage: item.serviceImage ?? '',
        date: item.date ?? '',
        timeSlot: item.timeSlot ?? '',
        durationMinutes: 60,
        status: item.status ?? 'Pending',
        customerNotes: null,
        createdAt: item.createdAt,
      );

      if (_isProvider) {
        Get.to(() => ProviderAppointmentDetailsScreen(
              booking: booking,
              onStatusChanged: () {
                context.read<NotificationBloc>().add(const NotificationFetchRequested());
              },
            ));
      } else {
        Get.to(() => BookingDetailsScreen(booking: booking));
      }
      return;
    }

    if (item.serviceId != null && item.serviceId!.isNotEmpty) {
      final service = ServiceModel(
        id: item.serviceId!,
        name: item.serviceName ?? item.title,
        category: 'Services',
        price: item.servicePrice ?? 0.0,
        durationMinutes: 60,
        imageUrl: item.serviceImage ?? '',
        rating: 4.9,
        totalReviews: 24,
        description: item.message,
        isFeatured: true,
      );
      Get.to(() => ServiceDetailsScreen(service: service));
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, NotificationModel item) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFECDD3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppSvgIcons.delete,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Delete Notification?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Are you sure you want to remove this notification?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                backgroundColor: const Color(0xFFF8FAFC),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Avatar / Image Builder ---
  Widget _buildLeadingImage(NotificationModel item) {
    // 1. If has Client Avatar / Profile Picture
    final hasAvatar = item.clientAvatar != null &&
        item.clientAvatar!.trim().isNotEmpty &&
        item.clientAvatar!.startsWith('http');

    // 2. If has Service Image
    final hasServiceImage = item.serviceImage != null &&
        item.serviceImage!.trim().isNotEmpty &&
        item.serviceImage!.startsWith('http');

    final displayImageUrl = hasAvatar ? item.clientAvatar! : (hasServiceImage ? item.serviceImage! : null);
    final iconColor = _getTypeColor(item.type);

    if (displayImageUrl != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: displayImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallbackIcon(item),
                errorWidget: (_, __, ___) => _fallbackIcon(item),
              ),
            ),
          ),
          Positioned(
            bottom: -3,
            right: -3,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(_getTypeIcon(item.type), color: Colors.white, size: 9),
              ),
            ),
          ),
        ],
      );
    }

    return _fallbackIcon(item);
  }

  Widget _fallbackIcon(NotificationModel item) {
    final iconColor = _getTypeColor(item.type);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.25), width: 1),
      ),
      child: Center(
        child: Icon(_getTypeIcon(item.type), color: iconColor, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(),
      child: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.status == NotificationStatus.success || state.status == NotificationStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final bloc = context.read<NotificationBloc>();
          final isLoading = (state.status == NotificationStatus.loading);

          // In Provider mode: filter out customer promo mock notifications if any
          List<NotificationModel> list = state.notifications;
          if (_isProvider) {
            list = list
                .where((n) {
                  final cleaned = _cleanTitle(n.title).toLowerCase();
                  return !cleaned.contains('welcome to service booking') &&
                      !cleaned.contains('discount available') &&
                      !cleaned.contains('ai assistant ready');
                })
                .toList();

            // If empty in provider mode or still loading, use actual appointment notifications
            if (list.isEmpty) {
              list = _fallbackProviderNotifications;
            }
          } else {
            if (list.isEmpty && isLoading) {
              list = _fallbackProviderNotifications;
            }
          }

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
                'Notifications',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
              actions: [
                if (list.any((n) => !n.isRead))
                  TextButton(
                    onPressed: () {
                      bloc.add(const NotificationMarkAllAsReadRequested());
                    },
                    child: const Text(
                      'Mark all',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
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
              onRefresh: () async {
                bloc.add(const NotificationFetchRequested());
                await Future.delayed(const Duration(milliseconds: 600));
                _refreshController.refreshCompleted();
              },
              child: Skeletonizer(
                enabled: isLoading && state.notifications.isEmpty,
                child: (list.isEmpty && !isLoading)
                    ? const EmptyScreenWidget(
                        title: 'No Notifications',
                        subtitle: 'You are all caught up! Updates, bookings, and alerts will appear here.',
                        icon: Icons.notifications_none_rounded,
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final hasActions = (_isProvider &&
                                  item.appointmentId != null &&
                                  (item.status ?? '').toLowerCase() == 'pending') ||
                              (!_isProvider &&
                                  item.appointmentId != null &&
                                  ((item.status ?? '').toLowerCase() == 'completed' || item.canReview) &&
                                  (item.rating == null || item.rating == 0));

                          return Dismissible(
                            key: Key('${item.id}_$index'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _showDeleteConfirmationDialog(context, item);
                            },
                            onDismissed: (direction) {
                              bloc.add(NotificationDeleteRequested(item.id));
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: SvgPicture.asset(
                                AppSvgIcons.delete,
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (!item.isRead) {
                                  bloc.add(NotificationMarkAsReadRequested(item.id));
                                }
                                _handleDeepLink(context, item);
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: item.isRead
                                        ? AppColors.strokeColor.withOpacity(0.85)
                                        : AppColors.primaryColor.withOpacity(0.35),
                                    width: item.isRead ? 1 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.025),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLeadingImage(item),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _cleanTitle(item.title),
                                                      style: TextStyle(
                                                        fontSize: 14.5,
                                                        fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                                                        color: AppColors.textPrimary,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!item.isRead) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.primaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.message,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: AppColors.textSecondary,
                                                  height: 1.35,
                                                ),
                                              ),
                                              if (item.date != null && item.date!.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.schedule_rounded,
                                                        size: 13, color: AppColors.textMuted),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${item.date}${item.timeSlot != null ? " • ${item.timeSlot}" : ""}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                    if (item.status != null && item.status!.isNotEmpty) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: _getStatusBadgeBg(item.status!),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          item.status!,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: _getStatusBadgeColor(item.status!),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Inline Quick Action Buttons
                                    if (hasActions) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                      const SizedBox(height: 10),
                                      if (_isProvider && (item.status ?? '').toLowerCase() == 'pending') ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              height: 34,
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.error,
                                                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                                ),
                                                onPressed: () => _showProviderDeclineDialog(context, item),
                                                child: const Text('Decline',
                                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              height: 34,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.primaryColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                ),
                                                onPressed: () => _showProviderConfirmDialog(context, item),
                                                child: const Text('Confirm',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (!_isProvider &&
                                          ((item.status ?? '').toLowerCase() == 'completed' || item.canReview)) ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            height: 34,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF59E0B),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                              ),
                                              onPressed: () => _showCustomerRatingDialog(context, item),
                                              icon: const Icon(Icons.star_rounded, size: 16),
                                              label: const Text('Rate Service',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
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

  Color _getStatusBadgeBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFDBEAFE);
      case 'completed':
        return const Color(0xFFDCFCE7);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2563EB);
      case 'completed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return AppColors.error;
      default:
        return const Color(0xFFD97706);
    }
  }
}

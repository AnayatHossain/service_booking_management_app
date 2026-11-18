import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/model/booking_model.dart';
import 'package:service_booking_management_app/feature/users/normal_user/my_bookings/widgets/booking_status_chip.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/widgets/provider_appointment_dialogs.dart';

class ProviderAppointmentDetailsScreen extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onStatusChanged;

  const ProviderAppointmentDetailsScreen({
    super.key,
    required this.booking,
    this.onStatusChanged,
  });

  @override
  State<ProviderAppointmentDetailsScreen> createState() => _ProviderAppointmentDetailsScreenState();
}

class _ProviderAppointmentDetailsScreenState extends State<ProviderAppointmentDetailsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late BookingModel _currentBooking;
  bool _isActionLoading = false;

  StreamSubscription<BookingStatusEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _fetchLatestBookingDetails();
    _eventSub = BookingEventBus.stream.listen((event) {
      if (!mounted) return;
      if (event.bookingId == _currentBooking.id) {
        setState(() {
          _currentBooking = _currentBooking.copyWith(status: event.newStatus);
        });
      }
    });
  }

  Future<void> _fetchLatestBookingDetails() async {
    final token = await Urls.bearerToken;
    final api = FlutterApiCraft(
      baseUrl: Urls.baseUrl,
      path: Urls.appointmentDetails(_currentBooking.id),
      apiType: ApiType.get,
      apiHeaders: {'Authorization': token},
      enableLoading: false,
      enableApiSuccessResponseGetSnackBar: false,
      enableApiErrorResponseGetSnackBar: false,
    );
    final res = await api.call();
    if (res.isSuccess && res.data is Map && res.data['data'] is Map) {
      if (mounted) {
        setState(() {
          _currentBooking = BookingModel.fromJson(res.data['data'] as Map<String, dynamic>);
        });
      }
    }
    _refreshController.refreshCompleted();
  }

  Widget _buildClientAvatar(String? avatarUrl, String name) {
    const defaultAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';
    final url = (avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http'))
        ? avatarUrl
        : defaultAvatar;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitialsAvatar(name),
          errorWidget: (_, __, ___) => _buildInitialsAvatar(name),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'C';
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    // 1. Optimistic Instant UI Update
    setState(() {
      _currentBooking = _currentBooking.copyWith(status: newStatus);
    });
    // Broadcast globally to all other screens (Dashboard, Bookings, Notifications)
    BookingEventBus.notifyStatusChanged(bookingId: _currentBooking.id, newStatus: newStatus);
    widget.onStatusChanged?.call();

    setState(() => _isActionLoading = true);
    final token = await Urls.bearerToken;
    final api = FlutterApiCraft(
      baseUrl: Urls.baseUrl,
      path: Urls.providerUpdateBookingStatus(_currentBooking.id, newStatus),
      apiType: ApiType.patch,
      apiHeaders: {'Authorization': token},
      enableLoading: true,
      enableApiSuccessResponseGetSnackBar: true,
      enableApiErrorResponseGetSnackBar: true,
    );
    final res = await api.call();
    if (res.isSuccess) {
      if (mounted) {
        setState(() {
          _currentBooking = _currentBooking.copyWith(status: newStatus);
          _isActionLoading = false;
        });
        widget.onStatusChanged?.call();
      }
    } else {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _showConfirmDialog() {
    ProviderAppointmentDialogs.showConfirmDialog(
      context,
      serviceName: _currentBooking.serviceName,
      serviceImage: _currentBooking.serviceImage,
      clientName: _currentBooking.userName.isNotEmpty ? _currentBooking.userName : 'Client',
      date: _currentBooking.date,
      timeSlot: _currentBooking.timeSlot,
      price: _currentBooking.servicePrice,
      onConfirm: () => _updateStatus('Confirmed'),
    );
  }

  void _showDeclineDialog() {
    ProviderAppointmentDialogs.showDeclineDialog(
      context,
      serviceName: _currentBooking.serviceName,
      serviceImage: _currentBooking.serviceImage,
      clientName: _currentBooking.userName.isNotEmpty ? _currentBooking.userName : 'Client',
      date: _currentBooking.date,
      timeSlot: _currentBooking.timeSlot,
      price: _currentBooking.servicePrice,
      onDecline: () => _updateStatus('Cancelled'),
    );
  }

  void _showCompleteDialog() {
    ProviderAppointmentDialogs.showCompleteDialog(
      context,
      serviceName: _currentBooking.serviceName,
      serviceImage: _currentBooking.serviceImage,
      clientName: _currentBooking.userName.isNotEmpty ? _currentBooking.userName : 'Client',
      date: _currentBooking.date,
      timeSlot: _currentBooking.timeSlot,
      price: _currentBooking.servicePrice,
      onComplete: () => _updateStatus('Completed'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = _currentBooking;

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
          'Appointment Details',
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
        onRefresh: _fetchLatestBookingDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Reference & Status Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.025),
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
                              'Appointment Reference',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 3),
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
                                      'Appointment ID copied to clipboard',
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
                    const Divider(height: 22, color: AppColors.strokeColor),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppSvgIcons.calendar,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date & Time', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
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
                      child: Container(
                        width: 70,
                        height: 70,
                        color: AppColors.bgColor,
                        child: booking.serviceImage.isNotEmpty && booking.serviceImage.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: booking.serviceImage,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _serviceImagePlaceholder(),
                                errorWidget: (_, __, ___) => _serviceImagePlaceholder(),
                              )
                            : _serviceImagePlaceholder(),
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.serviceCategory} • ${booking.durationMinutes} mins',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
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

              // 3. Client Information Card
              const Text(
                'Client Details',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildClientAvatar(booking.userAvatar, booking.userName),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client Name', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                booking.userName.isNotEmpty ? booking.userName : 'Client',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (booking.userEmail.isNotEmpty) ...[
                      const Divider(height: 18, color: AppColors.strokeColor),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppSvgIcons.mailOutline,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email Address', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  booking.userEmail,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: booking.userEmail));
                              Get.snackbar('Copied', 'Email copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                            },
                            child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 4. Customer Notes Card
              if (booking.customerNotes != null && booking.customerNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Client Special Note',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, color: Color(0xFF94A3B8), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.customerNotes!.trim(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 5. Client Rating & Review (if rated by client)
              if (booking.isRated || (booking.rating != null && booking.rating! > 0)) ...[
                const SizedBox(height: 20),
                const Text(
                  'Client Rating & Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFEF08A), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF9C3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${booking.rating?.toStringAsFixed(1) ?? "5.0"}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 16),
                                    ],
                                  ),
                                  const Text(
                                    'Client Rating',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Rated',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCA8A04)),
                            ),
                          ),
                        ],
                      ),
                      if (booking.review != null && booking.review!.trim().isNotEmpty) ...[
                        const Divider(height: 20, color: Color(0xFFFEF08A)),
                        Text(
                          '"${booking.review!.trim()}"',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // 6. Actions
              if (booking.isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isActionLoading ? null : _showDeclineDialog,
                        child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isActionLoading ? null : _showConfirmDialog,
                        child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.isConfirmed) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isActionLoading ? null : _showCompleteDialog,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text('Mark Completed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceImagePlaceholder() {
    return Container(
      color: AppColors.primaryColor.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.home_repair_service_rounded, color: AppColors.primaryColor, size: 28),
      ),
    );
  }
}

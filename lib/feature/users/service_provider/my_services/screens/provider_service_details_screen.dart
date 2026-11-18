import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/model/service_model.dart';
import '../widgets/provider_delete_service_dialog.dart';
import 'provider_add_edit_service_screen.dart';

class ProviderServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback? onServiceUpdated;
  final VoidCallback? onServiceDeleted;

  const ProviderServiceDetailsScreen({
    super.key,
    required this.service,
    this.onServiceUpdated,
    this.onServiceDeleted,
  });

  @override
  State<ProviderServiceDetailsScreen> createState() => _ProviderServiceDetailsScreenState();
}

class _ProviderServiceDetailsScreenState extends State<ProviderServiceDetailsScreen> {
  late ServiceModel _service;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _fetchLatestDetails();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestDetails() async {
    setState(() => _isLoading = true);
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.serviceDetails(_service.id),
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final res = await api.call();
      if (res.isSuccess && res.data is Map && res.data['data'] is Map) {
        if (mounted) {
          setState(() {
            _service = ServiceModel.fromJson(Map<String, dynamic>.from(res.data['data']));
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
      _refreshController.refreshCompleted();
    }
  }

  Future<void> _handleEdit() async {
    final updated = await Get.to<ServiceModel>(
      () => ProviderAddEditServiceScreen(service: _service),
    );
    if (updated != null && mounted) {
      setState(() {
        _service = updated;
      });
      widget.onServiceUpdated?.call();
      _fetchLatestDetails();
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await ProviderDeleteServiceDialog.show(
      context,
      serviceName: _service.name,
    );
    if (confirmed == true) {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerDeleteService(_service.id),
        apiType: ApiType.delete,
        apiHeaders: {'Authorization': token},
        enableLoading: true,
        enableApiSuccessResponseGetSnackBar: true,
        enableApiErrorResponseGetSnackBar: true,
      );
      final res = await api.call();
      if (res.isSuccess) {
        widget.onServiceDeleted?.call();
        Get.back(result: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
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
        onRefresh: _fetchLatestDetails,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sliver Image AppBar with Edit & Delete actions
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.45),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      AppSvgIcons.backArrow,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.45),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppSvgIcons.edit,
                        width: 17,
                        height: 17,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: _handleEdit,
                      tooltip: 'Edit Service',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFDC2626).withOpacity(0.85),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppSvgIcons.delete,
                        width: 17,
                        height: 17,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: _handleDelete,
                      tooltip: 'Delete Service',
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _service.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.primaryLight),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.broken_image_rounded, size: 60, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _service.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  '${_service.rating.toStringAsFixed(1)} (${_service.totalReviews} reviews)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Body with Skeletonizer
            SliverToBoxAdapter(
              child: Skeletonizer(
                enabled: _isLoading,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name & Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _service.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '\$${_service.price.toStringAsFixed(_service.price.truncateToDouble() == _service.price ? 0 : 1)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Metrics Cards
                      Row(
                        children: [
                          _buildMetricCard(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF2563EB),
                            title: 'Duration',
                            value: '${_service.durationMinutes} mins',
                          ),
                          const SizedBox(width: 10),
                          _buildMetricCard(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Rating',
                            value: '${_service.rating.toStringAsFixed(1)}★',
                          ),
                          const SizedBox(width: 10),
                          _buildMetricCard(
                            icon: Icons.verified_rounded,
                            iconColor: const Color(0xFF10B981),
                            title: 'Status',
                            value: 'Active',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildContentCard(
                        title: 'About This Service',
                        icon: Icons.description_outlined,
                        child: Text(
                          _service.description.isNotEmpty
                              ? _service.description
                              : 'Professional quality ${_service.name} service provided with industry-standard expertise and customer satisfaction guarantee.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // What's Included
                      _buildContentCard(
                        title: "What's Included",
                        icon: Icons.check_circle_outline_rounded,
                        child: Column(
                          children: _service.includes.map((inc) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      inc,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Available Days
                      if (_service.availableDays.isNotEmpty) ...[
                        _buildContentCard(
                          title: 'Available Service Days',
                          icon: Icons.calendar_today_rounded,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _service.availableDays.map((day) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                                ),
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Available Time Slots
                      if (_service.timeSlots.isNotEmpty) ...[
                        _buildContentCard(
                          title: 'Bookable Time Slots',
                          icon: Icons.schedule_rounded,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _service.timeSlots.map((slot) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  slot,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _handleDelete,
                    icon: SvgPicture.asset(
                      AppSvgIcons.delete,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Color(0xFFDC2626), BlendMode.srcIn),
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _handleEdit,
                    icon: SvgPicture.asset(
                      AppSvgIcons.edit,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    label: const Text(
                      'Edit Service',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  String _formatJoinDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Active Member';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('MMMM yyyy').format(dt);
    } catch (_) {
      return 'Active Member';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const ProfileLoadRequested()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success || state.status == ProfileStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final bloc = context.read<ProfileBloc>();
          final bool isLoading = state.status == ProfileStatus.loading && state.name.isEmpty;

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Settings & Security',
                  icon: SvgPicture.asset(
                    AppSvgIcons.settingsFilled,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Get.to(() => const SettingsScreen());
                  },
                ),
                const SizedBox(width: 8),
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
              onRefresh: () {
                bloc.add(const ProfileLoadRequested());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profile Hero Card
                        _buildHeroCard(state),
                        const SizedBox(height: 20),

                        // 2. Lifetime Booking Statistics Grid
                        const Text(
                          'Booking Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatsGrid(state),
                        const SizedBox(height: 24),

                        // 3. Contact & Personal Info Details
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(context, state),
                        const SizedBox(height: 20),
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

  Widget _buildHeroCard(ProfileState state) {
    final displayName = state.name.isNotEmpty ? state.name : 'Customer';
    final isProvider = state.role.toLowerCase().contains('provider') ||
        state.role.toLowerCase().contains('service') ||
        state.email.toLowerCase().contains('provider');
    final hasAvatar = state.avatarUrl != null &&
        state.avatarUrl!.isNotEmpty &&
        state.avatarUrl!.startsWith('http');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFF2563EB), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasAvatar
                      ? CachedNetworkImage(
                          imageUrl: state.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _initialsAvatar(displayName),
                          errorWidget: (_, __, ___) => _initialsAvatar(displayName),
                        )
                      : _initialsAvatar(displayName),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 20,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          if (state.organizationName != null && state.organizationName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppSvgIcons.enterprise,
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
                ),
                const SizedBox(width: 5),
                Text(
                  state.organizationName!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isProvider ? 'Verified Provider' : 'Verified Customer',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String name) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProfileState state) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Total',
            value: '${state.totalBookings}',
            subtitle: 'Bookings',
            svgAsset: AppSvgIcons.calendar,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Active',
            value: '${state.activeBookings}',
            subtitle: 'Upcoming',
            svgAsset: AppSvgIcons.clock,
            color: Colors.amber.shade800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Done',
            value: '${state.completedBookings}',
            subtitle: 'Completed',
            svgAsset: AppSvgIcons.completedTask,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Cancelled',
            value: '${state.cancelledBookings}',
            subtitle: 'Cancelled',
            svgAsset: AppSvgIcons.close,
            color: Colors.red.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    String? svgAsset,
    IconData? icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          if (svgAsset != null)
            SvgPicture.asset(
              svgAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          else if (icon != null)
            Icon(icon, color: color, size: 20)
          else
            const SizedBox(height: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, ProfileState state) {
    final displayEmail = state.email.isNotEmpty ? state.email : 'user@example.com';
    final hasPhone = state.phone != null && state.phone!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            svgAsset: AppSvgIcons.telephone,
            label: 'Phone Number',
            value: hasPhone ? state.phone! : 'Not provided yet',
            isActionable: hasPhone,
            onAction: () {
              if (hasPhone) {
                Clipboard.setData(ClipboardData(text: state.phone!));
                Get.snackbar(
                  'Copied',
                  'Phone number copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.white,
                  colorText: AppColors.textPrimary,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
          ),
          const Divider(height: 24, thickness: 0.7, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            svgAsset: AppSvgIcons.mailFilled,
            label: 'Email Address',
            value: displayEmail,
            isActionable: state.email.isNotEmpty,
            onAction: () {
              Clipboard.setData(ClipboardData(text: displayEmail));
              Get.snackbar(
                'Copied',
                'Email address copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.white,
                colorText: AppColors.textPrimary,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          const Divider(height: 24, thickness: 0.7, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            svgAsset: AppSvgIcons.calendar,
            label: 'Member Since',
            value: _formatJoinDate(state.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    String? svgAsset,
    IconData? icon,
    required String label,
    required String value,
    Widget? badge,
    bool isActionable = false,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: svgAsset != null
              ? SvgPicture.asset(
                  svgAsset,
                  width: 19,
                  height: 19,
                  colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
                )
              : Icon(icon ?? Icons.info_outline, color: const Color(0xFF2563EB), size: 19),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (badge != null) badge,
        if (isActionable)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.copy_rounded, size: 17, color: Color(0xFF2563EB)),
            ),
          ),
      ],
    );
  }
}

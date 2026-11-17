import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import 'package:service_booking_management_app/core/const/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_screen.dart';
import 'profile_screen.dart';

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
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: const Text(
                'User Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Settings & Security',
                  icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 22),
                  onPressed: () {
                    Get.to(() => const ProfileScreen());
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
              child: Skeletonizer(
                enabled: isLoading,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                      const SizedBox(height: 28),

                      // 4. Primary Actions
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Get.to(() => EditProfileScreen(
                                  initialName: state.name,
                                  initialPhone: state.phone ?? '',
                                  initialAvatarUrl: state.avatarUrl ?? '',
                                ));
                            if (updated == true) {
                              bloc.add(const ProfileLoadRequested());
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(() => const ProfileScreen());
                          },
                          icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryColor),
                          label: const Text(
                            'Account Settings & Security',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
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

  Widget _buildHeroCard(ProfileState state) {
    final displayName = state.name.isNotEmpty ? state.name : 'Customer';
    final displayEmail = state.email.isNotEmpty ? state.email : 'user@example.com';
    final hasAvatar = state.avatarUrl != null &&
        state.avatarUrl!.isNotEmpty &&
        state.avatarUrl!.startsWith('http');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.primaryColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.18),
                      blurRadius: 12,
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
                  padding: const EdgeInsets.all(3),
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
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayEmail,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
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
                  'Verified ${state.role.capitalizeFirst ?? "Customer"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
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
            icon: Icons.calendar_month_rounded,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Active',
            value: '${state.activeBookings}',
            subtitle: 'Upcoming',
            icon: Icons.access_time_rounded,
            color: Colors.amber.shade800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Done',
            value: '${state.completedBookings}',
            subtitle: 'Completed',
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Cancelled',
            value: '${state.cancelledBookings}',
            subtitle: 'Cancelled',
            icon: Icons.cancel_outlined,
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
    required IconData icon,
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
          Icon(icon, color: color, size: 20),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: (state.phone != null && state.phone!.isNotEmpty) ? state.phone! : 'Not provided yet',
            isActionable: state.phone != null && state.phone!.isNotEmpty,
            onAction: () {
              if (state.phone != null && state.phone!.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: state.phone!));
                Get.snackbar('Copied', 'Phone number copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
              }
            },
          ),
          const Divider(height: 24, thickness: 0.7),
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email Status',
            value: 'Verified & Active',
            badge: const Text(
              'Verified',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ),
          const Divider(height: 24, thickness: 0.7),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Member Since',
            value: _formatJoinDate(state.createdAt),
          ),
          const Divider(height: 24, thickness: 0.7),
          _buildInfoRow(
            icon: Icons.shield_outlined,
            label: 'Account Protection',
            value: 'Standard Session Security',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? badge,
    bool isActionable = false,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 18),
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
              ),
            ],
          ),
        ),
        if (badge != null) badge,
        if (isActionable)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryColor),
            onPressed: onAction,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

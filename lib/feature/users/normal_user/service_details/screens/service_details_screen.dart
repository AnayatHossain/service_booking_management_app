import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import '../../appointment/screen/appointment_screen.dart';
import '../../home_screen/model/service_model.dart';
import '../bloc/service_details_bloc.dart';
import '../bloc/service_details_event.dart';
import '../bloc/service_details_state.dart';
import '../widgets/book_bottom_bar.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceDetailsBloc(initialService: widget.service)
        ..add(ServiceDetailsFetchRequested(widget.service.id)),
      child: BlocConsumer<ServiceDetailsBloc, ServiceDetailsState>(
        listener: (context, state) {
          if (state.status == ServiceDetailsStatus.success || state.status == ServiceDetailsStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final current = state.service ?? widget.service;
          final isLoading = state.status == ServiceDetailsStatus.loading;

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
              onRefresh: () {
                context.read<ServiceDetailsBloc>().add(ServiceDetailsFetchRequested(widget.service.id));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                    // Premium Collapsible Sliver Image App Bar
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: AppColors.primaryColor,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
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
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.4),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                AppSvgIcons.share,
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                              onPressed: () {
                                final shareText = '''
✨ Check out "${current.name}" on Service Booking App!

🏷️ Category: ${current.category}
💰 Price: \$${current.price.toStringAsFixed(2)}
⏱️ Duration: ${current.durationMinutes} mins
⭐ Rating: ${current.rating} (${current.totalReviews} reviews)

📝 Description:
${current.description}

📲 Book your appointment on Service Booking & Management App!
${current.imageUrl}
''';
                                SharePlus.instance.share(
                                  ShareParams(
                                    text: shareText,
                                    subject: 'Book ${current.name} on Service Booking App',
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: current.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.primaryLight,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.broken_image, size: 60, color: AppColors.primaryColor),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                            // Category & Rating Overlay Chips
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
                                      current.category.toUpperCase(),
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
                                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${current.rating} (${current.totalReviews} reviews)',
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

                    // Body Content
                    SliverToBoxAdapter(
                      child: Skeletonizer(
                        enabled: isLoading,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                current.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Price Tag under Title
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '\$${current.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                            // Highlights Row: Duration & Availability
                            Row(
                              children: [
                                _buildHighlightPill(
                                  Icons.access_time_rounded,
                                  'Duration',
                                  '${current.durationMinutes} mins',
                                ),
                                const SizedBox(width: 12),
                                _buildHighlightPill(
                                  Icons.verified_rounded,
                                  'Guarantee',
                                  '100% Protected',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Description Section
                            const Text(
                              'Service Description',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              current.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // What is Included Checklist Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
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
                                  const Text(
                                    'What is Included',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (current.includes.isNotEmpty)
                                    ...current.includes.map((item) => _buildFeatureItem(Icons.verified_outlined, item))
                                  else ...[
                                    _buildFeatureItem(Icons.verified_user_outlined, 'Vetted & background checked professionals'),
                                    _buildFeatureItem(Icons.timer_outlined, '${current.durationMinutes} mins comprehensive servicing'),
                                    _buildFeatureItem(Icons.thumb_up_alt_outlined, 'Full satisfaction guarantee with free rework'),
                                    _buildFeatureItem(Icons.support_agent_outlined, '24/7 dedicated in-app support & easy cancel'),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Available Schedule Days
                            if (current.availableDays.isNotEmpty || isLoading) ...[
                              const Text(
                                'Available Service Days',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (current.availableDays.isNotEmpty
                                        ? current.availableDays
                                        : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                                    .map((day) => Chip(
                                          label: Text(day),
                                          labelStyle: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          backgroundColor: AppColors.primaryLight,
                                          side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ))
                                    .toList(),
                              ),
                            ],

                            // Available Service Hours (Time Slots)
                            if (current.timeSlots.isNotEmpty || isLoading) ...[
                              const SizedBox(height: 22),
                              const Text(
                                'Available Service Hours',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (current.timeSlots.isNotEmpty
                                        ? current.timeSlots
                                        : const [
                                            '09:00 AM',
                                            '10:00 AM',
                                            '11:00 AM',
                                            '01:00 PM',
                                            '02:00 PM',
                                            '03:00 PM'
                                          ])
                                    .map((slot) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.primaryColor.withOpacity(0.35)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryColor.withOpacity(0.04),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.access_time_rounded,
                                                  size: 14, color: AppColors.primaryColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                slot,
                                                style: const TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BookBottomBar(
              price: current.price,
              onBookNow: () {
                Get.to(() => AppointmentScreen(service: current));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightPill(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.strokeColor.withOpacity(0.8)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

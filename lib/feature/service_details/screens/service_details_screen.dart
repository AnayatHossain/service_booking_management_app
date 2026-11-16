import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../appointment/screen/appointment_screen.dart';
import '../../home_screen/model/service_model.dart';
import '../bloc/service_details_bloc.dart';
import '../bloc/service_details_event.dart';
import '../bloc/service_details_state.dart';
import '../widgets/book_bottom_bar.dart';
import '../widgets/service_info_header.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceDetailsBloc(initialService: service)
        ..add(ServiceDetailsFetchRequested(service.id)),
      child: BlocBuilder<ServiceDetailsBloc, ServiceDetailsState>(
        builder: (context, state) {
          final current = state.service ?? service;

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            body: CustomScrollView(
              slivers: [
                // Collapsible Image App Bar
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppColors.primaryColor,
                  leading: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          current.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
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
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Info Header
                        ServiceInfoHeader(service: current),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'About this service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

                        // Service Features / Highlights
                        const Text(
                          'What is Included',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(Icons.verified_user_outlined, 'Vetted & Background Checked Professionals'),
                        _buildFeatureItem(Icons.timer_outlined, '${current.durationMinutes} minutes dedicated service time'),
                        _buildFeatureItem(Icons.thumb_up_alt_outlined, '100% Satisfaction Guarantee & Damage Protection'),
                        _buildFeatureItem(Icons.support_agent_outlined, '24/7 In-App Support & Easy Cancellation'),
                        const SizedBox(height: 24),

                        // Available Days
                        if (current.availableDays.isNotEmpty) ...[
                          const Text(
                            'Available Schedule',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: current.availableDays
                                .map((day) => Chip(
                                      label: Text(day, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: AppColors.primaryLight,
                                      side: BorderSide.none,
                                    ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

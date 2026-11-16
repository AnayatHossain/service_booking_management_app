import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/const/app_colors.dart';
import '../controllers/service_details_controller.dart';
import '../widgets/service_info_header.dart';
import '../widgets/book_bottom_bar.dart';
import '../../appointment/screens/appointment_booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceDetailsController(serviceId: serviceId), tag: serviceId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final service = controller.service.value;
        if (service == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : 'Service details unavailable'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Get.back(), child: const Text('Go Back')),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App Bar with Image
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    backgroundColor: AppColors.primaryColor,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.85),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: service.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.image, size: 60, color: AppColors.primaryColor),
                        ),
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
                          ServiceInfoHeader(service: service),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: AppColors.strokeColor),
                          const SizedBox(height: 20),

                          const Text(
                            'About this Service',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Available Days',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: service.availableDays.map((day) => Chip(
                              label: Text(day, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.bgColor,
                              side: const BorderSide(color: AppColors.strokeColor),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Typical Time Slots',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: service.timeSlots.map((slot) => Chip(
                              label: Text(slot, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primaryLight,
                              labelStyle: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              side: BorderSide.none,
                            )).toList(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Book Bar
            BookBottomBar(
              price: service.price,
              onBookTap: () => Get.to(() => AppointmentBookingScreen(service: service)),
            ),
          ],
        );
      }),
    );
  }
}

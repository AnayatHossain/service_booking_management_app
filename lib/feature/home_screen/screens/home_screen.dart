import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/category_selector.dart';
import '../widgets/featured_banner.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.handshake_outlined, color: AppColors.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Book trusted experts nearby',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: controller.fetchAllHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Obx(() => SearchFilterBar(
                currentQuery: controller.searchQuery.value,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              )),
              const SizedBox(height: 20),

              // Featured / Popular Services
              Obx(() {
                if (controller.featuredServices.isNotEmpty && controller.searchQuery.value.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured & Popular',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FeaturedBanner(services: controller.featuredServices),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Categories Chips
              const Text(
                'Categories',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Obx(() => CategorySelector(
                categories: controller.categories,
                selectedCategory: controller.selectedCategory.value,
                onSelected: controller.onCategorySelected,
              )),
              const SizedBox(height: 24),

              // Available Services Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Services',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Obx(() => Text(
                    '${controller.services.length} items',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )),
                ],
              ),
              const SizedBox(height: 14),

              // Services List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    ),
                  );
                }

                if (controller.services.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No services match your criteria.',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () {
                              controller.clearSearch();
                              controller.onCategorySelected('All');
                            },
                            child: const Text('Reset Filters', style: TextStyle(color: AppColors.primaryColor)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ServiceCard(service: controller.services[index]);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

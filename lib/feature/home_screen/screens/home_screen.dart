import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/empty_screen_widget.dart';
import '../../appointment/screen/appointment_screen.dart';
import '../../service_details/screens/service_details_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/featured_banner.dart';
import '../widgets/category_selector.dart';
import '../widgets/service_card.dart';
import '../widgets/home_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, HomeState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.strokeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: state.categories.map((cat) {
                  final isSelected = cat.toLowerCase() == state.selectedCategory.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor: AppColors.bgColor,
                    onSelected: (_) {
                      context.read<HomeBloc>().add(HomeCategorySelected(cat));
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeCategorySelected('All'));
                    _searchController.clear();
                    context.read<HomeBloc>().add(const HomeSearchChanged(''));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Reset All Filters', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar with User Greeting, Avatar & Badges
                HomeHeader(
                  userName: state.userName,
                  userEmail: state.userEmail,
                  avatarUrl: state.userAvatar,
                  onNotificationTap: () {
                    Get.snackbar(
                      'Notifications',
                      'You are all caught up! No new notifications.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.white,
                      colorText: AppColors.textPrimary,
                    );
                  },
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SearchFilterBar(
                    controller: _searchController,
                    onChanged: (val) {
                      context.read<HomeBloc>().add(HomeSearchChanged(val));
                    },
                    onClear: () {
                      context.read<HomeBloc>().add(const HomeSearchChanged(''));
                    },
                    onFilterTap: () => _showFilterBottomSheet(context, state),
                  ),
                ),

                // Main Scrollable Area
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () async {
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    child: (state.status == HomeStatus.loading && state.allServices.isEmpty)
                        ? const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: HomeShimmer(),
                            ),
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              // Featured Banner (if search is empty)
                              if (state.searchQuery.isEmpty && state.featuredServices.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Special Offers & Featured',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.local_fire_department_rounded, size: 18, color: Colors.deepOrange),
                                    ],
                                  ),
                                ),
                                FeaturedBanner(
                                  services: state.featuredServices,
                                  onServiceTap: (service) {
                                    Get.to(() => ServiceDetailsScreen(service: service));
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Categories
                              if (state.searchQuery.isEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                                  child: Text(
                                    'Categories',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                CategorySelector(
                                  categories: state.categories,
                                  selectedCategory: state.selectedCategory,
                                  onSelect: (cat) {
                                    context.read<HomeBloc>().add(HomeCategorySelected(cat));
                                  },
                                ),
                                const SizedBox(height: 18),
                              ],

                              // Available Services Section Title & Count Badge
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      state.searchQuery.isNotEmpty
                                          ? 'Search Results'
                                          : (state.selectedCategory == 'All'
                                              ? 'Available Services'
                                              : '${state.selectedCategory} Services'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${state.filteredServices.length} items',
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Services List or Empty State
                              if (state.filteredServices.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: EmptyScreenWidget(
                                    title: 'No services found',
                                    subtitle: state.searchQuery.isNotEmpty
                                        ? 'No services match "${state.searchQuery}". Try different keywords.'
                                        : 'No services currently listed in this category.',
                                    icon: Icons.search_off_rounded,
                                    buttonText: 'Reset Filters',
                                    onTap: () {
                                      _searchController.clear();
                                      context.read<HomeBloc>().add(const HomeSearchChanged(''));
                                      context.read<HomeBloc>().add(const HomeCategorySelected('All'));
                                    },
                                  ),
                                )
                              else
                                ...state.filteredServices.map(
                                  (service) => ServiceCard(
                                    service: service,
                                    onTap: () {
                                      Get.to(() => ServiceDetailsScreen(service: service));
                                    },
                                    onBookNow: () {
                                      Get.to(() => AppointmentScreen(service: service));
                                    },
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

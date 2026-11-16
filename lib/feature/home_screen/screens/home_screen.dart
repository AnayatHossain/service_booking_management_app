import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/const/app_colors.dart';
import '../../../../core/global_widegts/empty_screen_widget.dart';
import '../../appointment/screen/appointment_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../service_details/screens/service_details_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/home_header.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/featured_banner.dart';
import '../widgets/category_selector.dart';
import '../widgets/service_card.dart';
import '../model/service_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context, HomeState state) {
    showDialog(
      context: context,
      builder: (ctx) => FilterDialog(
        categories: state.categories,
        currentCategory: state.selectedCategory,
        currentSort: state.sortOption,
        onApply: (selectedCat, sortOpt) {
          context.read<HomeBloc>().add(HomeFilterApplied(
                category: selectedCat,
                sortOption: sortOpt,
              ));
        },
        onReset: () {
          _searchController.clear();
          context.read<HomeBloc>().add(const HomeFilterReset());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.status == HomeStatus.success || state.status == HomeStatus.failure) {
          _refreshController.refreshCompleted();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar: User Greeting, Avatar (tappable to Profile), and Notification Bell
                HomeHeader(
                  userName: state.userName,
                  userEmail: state.userEmail,
                  avatarUrl: state.userAvatar,
                  onProfileTap: () {
                    Get.to(() => const ProfileScreen());
                  },
                  onNotificationTap: () {
                    Get.to(() => const NotificationScreen());
                  },
                ),

                // Search Bar with Filter Dialog trigger
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
                    onFilterTap: () => _showFilterDialog(context, state),
                  ),
                ),

                // Main Content Area with Pull-To-Refresh (WaterDropMaterialHeader)
                Expanded(
                  child: SmartRefresher(
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
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    child: Skeletonizer(
                      enabled: state.status == HomeStatus.loading && state.allServices.isEmpty,
                      child: _buildBody(context, state),
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

  static final List<ServiceModel> _dummyServices = List.generate(
    4,
    (i) => ServiceModel(
      id: 'dummy_$i',
      name: 'Executive Haircut & Beard Styling',
      description: 'Precision haircut, hot towel therapy, beard shaping and premium treatment',
      category: 'Beauty & Salon',
      price: 35.0,
      durationMinutes: 45,
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      rating: 4.85,
      totalReviews: 120,
      isFeatured: true,
    ),
  );

  Widget _buildBody(BuildContext context, HomeState state) {
    final bool isLoading = state.status == HomeStatus.loading && state.allServices.isEmpty;

    // Error State (Retry View)
    if (state.status == HomeStatus.failure && state.allServices.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_off_rounded, size: 36, color: Colors.red.shade400),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Connection Failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unable to connect to the service booking server. Please check your connection.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeDataRequested());
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayFeatured = isLoading ? _dummyServices.take(2).toList() : state.featuredServices;
    final displayCategories = isLoading
        ? const ['All', 'Appliance Repair', 'Automotive', 'Beauty & Salon', 'Cleaning']
        : state.categories;
    final displayServices = isLoading ? _dummyServices : state.filteredServices;

    // Return ListView directly as child of SmartRefresher
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
          // Featured Banner Carousel
          if (state.searchQuery.isEmpty && displayFeatured.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
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
              services: displayFeatured,
              onServiceTap: isLoading
                  ? (_) {}
                  : (service) {
                      Get.to(() => ServiceDetailsScreen(service: service));
                    },
            ),
            const SizedBox(height: 14),
          ],

          // Categories Selector
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
              categories: displayCategories,
              selectedCategory: state.selectedCategory,
              onSelect: isLoading
                  ? (_) {}
                  : (cat) {
                      context.read<HomeBloc>().add(HomeCategorySelected(cat));
                    },
            ),
            const SizedBox(height: 18),
          ],

          // Section Title & Result Count
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
                    '${displayServices.length} found',
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

          // Service Cards or Empty State
          if (!isLoading && displayServices.isEmpty)
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
                  context.read<HomeBloc>().add(const HomeFilterReset());
                },
              ),
            )
          else
            ...displayServices.map(
              (service) => ServiceCard(
                service: service,
                onTap: isLoading
                    ? () {}
                    : () {
                        Get.to(() => ServiceDetailsScreen(service: service));
                      },
                onBookNow: isLoading
                    ? () {}
                    : () {
                        Get.to(() => AppointmentScreen(service: service));
                      },
              ),
            ),
        ],
      );
  }
}

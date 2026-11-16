import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
    return BlocBuilder<HomeBloc, HomeState>(
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

                // Main Content Area with Pull-To-Refresh
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () async {
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    child: _buildBody(context, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    // 1. Loading State (Initial Shimmer)
    if (state.status == HomeStatus.loading && state.allServices.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 14),
          child: HomeShimmer(),
        ),
      );
    }

    // 2. Error State (Retry View)
    if (state.status == HomeStatus.failure && state.allServices.isEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
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

    // 3. Success State
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Featured Banner Carousel (shown when no search filter is active)
        if (state.searchQuery.isEmpty && state.featuredServices.isNotEmpty) ...[
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
            services: state.featuredServices,
            onServiceTap: (service) {
              Get.to(() => ServiceDetailsScreen(service: service));
            },
          ),
          const SizedBox(height: 14),
        ],

        // Horizontal Category Selector
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
                  '${state.filteredServices.length} found',
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

        // 4. Empty State or List
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
                context.read<HomeBloc>().add(const HomeFilterReset());
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
    );
  }
}

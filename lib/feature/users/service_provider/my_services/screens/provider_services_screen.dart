import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/model/service_model.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/widgets/search_filter_bar.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/widgets/filter_dialog.dart';
import '../../../../../core/global_widegts/empty_screen_widget.dart';
import '../bloc/provider_services_bloc.dart';
import '../bloc/provider_services_event.dart';
import '../bloc/provider_services_state.dart';
import '../widgets/provider_service_card.dart';
import '../widgets/provider_delete_service_dialog.dart';
import 'provider_service_details_screen.dart';
import 'provider_add_edit_service_screen.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  // Fallback demo services for skeletonizer and graceful presentation
  final List<ServiceModel> _dummyServices = [
    ServiceModel(
      id: 'demo_1',
      name: 'Full House Deep Cleaning',
      description: 'Comprehensive top-to-bottom house deep cleaning service.',
      category: 'Home Cleaning',
      price: 120.0,
      durationMinutes: 180,
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      rating: 4.9,
      totalReviews: 48,
    ),
    ServiceModel(
      id: 'demo_2',
      name: 'Luxury Aromatherapy Spa & Massage',
      description: 'Relaxing holistic full body oil massage.',
      category: 'Spa & Wellness',
      price: 85.0,
      durationMinutes: 90,
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
      rating: 4.95,
      totalReviews: 36,
    ),
    ServiceModel(
      id: 'demo_3',
      name: 'Air Conditioner Master Servicing',
      description: 'Filter cleaning, gas level test, and coil sanitization.',
      category: 'Appliance Repair',
      price: 45.0,
      durationMinutes: 60,
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      rating: 4.8,
      totalReviews: 52,
    ),
    ServiceModel(
      id: 'demo_4',
      name: 'Executive Haircut & Beard Styling',
      description: 'Master barber haircut and precision hot towel beard trim.',
      category: 'Beauty & Salon',
      price: 35.0,
      durationMinutes: 45,
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
      rating: 4.85,
      totalReviews: 29,
    ),
  ];

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context, ProviderServicesState state) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => FilterDialog(
        categories: state.categories,
        currentCategory: state.selectedCategory,
        currentSort: state.sortOption,
        onApply: (selectedCat, sortOpt) {
          context.read<ProviderServicesBloc>().add(ProviderServicesFilterApplied(
                category: selectedCat,
                sortOption: sortOpt,
              ));
        },
        onReset: () {
          _searchController.clear();
          context.read<ProviderServicesBloc>().add(const ProviderServicesFilterReset());
        },
      ),
    );
  }

  void _navigateToAddService(BuildContext context) async {
    final result = await Get.to(() => const ProviderAddEditServiceScreen());
    if (result != null && result is ServiceModel && context.mounted) {
      context.read<ProviderServicesBloc>().add(ProviderServiceOptimisticAddOrUpdate(result));
      context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
    }
  }

  void _navigateToEditService(BuildContext context, ServiceModel service) async {
    final result = await Get.to(() => ProviderAddEditServiceScreen(service: service));
    if (result != null && result is ServiceModel && context.mounted) {
      context.read<ProviderServicesBloc>().add(ProviderServiceOptimisticAddOrUpdate(result));
      context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
    }
  }

  void _handleDeleteService(BuildContext context, ServiceModel service) async {
    final confirmed = await ProviderDeleteServiceDialog.show(
      context,
      serviceName: service.name,
    );
    if (confirmed == true && context.mounted) {
      context.read<ProviderServicesBloc>().add(ProviderServiceDeleteRequested(service.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProviderServicesBloc()..add(const ProviderServicesFetchRequested()),
      child: BlocConsumer<ProviderServicesBloc, ProviderServicesState>(
        listener: (context, state) {
          if (state.status == ProviderServicesStatus.success || state.status == ProviderServicesStatus.failure) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProviderServicesStatus.loading;
          final List<ServiceModel> displayList =
              state.services.isNotEmpty ? state.services : (isLoading ? _dummyServices : []);

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'My Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      // Search Bar with Filter Dialog trigger (Identical to Home Screen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: SearchFilterBar(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<ProviderServicesBloc>().add(ProviderServicesSearchChanged(val));
                          },
                          onClear: () {
                            context.read<ProviderServicesBloc>().add(const ProviderServicesSearchChanged(''));
                          },
                          onFilterTap: () => _showFilterDialog(context, state),
                        ),
                      ),

                      // Main Content Area with Pull-To-Refresh
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
                            context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
                          },
                          child: (displayList.isEmpty && !isLoading)
                              ? const SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 60),
                                    child: EmptyScreenWidget(
                                      title: 'No Services Listed',
                                      subtitle: 'Publish your service offerings so clients can discover and book your expert services.',
                                      icon: Icons.inventory_2_outlined,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
                                  itemCount: displayList.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final item = displayList[idx];
                                    return Skeletonizer(
                                      enabled: isLoading,
                                      child: ProviderServiceCard(
                                        service: item,
                                        onTap: () async {
                                          await Get.to(() => ProviderServiceDetailsScreen(
                                                service: item,
                                                onServiceUpdated: () {
                                                  context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
                                                },
                                                onServiceDeleted: () {
                                                  context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
                                                },
                                              ));
                                          if (context.mounted) {
                                            context.read<ProviderServicesBloc>().add(const ProviderServicesFetchRequested());
                                          }
                                        },
                                        onEdit: () => _navigateToEditService(context, item),
                                        onDelete: () => _handleDeleteService(context, item),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Add Service Button positioned on the right side above the Bottom Navigation Bar with comfortable gap
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryColor, Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: () => _navigateToAddService(context),
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Add Service',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

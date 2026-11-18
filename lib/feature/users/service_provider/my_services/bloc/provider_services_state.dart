import 'package:equatable/equatable.dart';
import '../../../normal_user/home_screen/model/service_model.dart';
import '../../../normal_user/home_screen/widgets/filter_dialog.dart';

enum ProviderServicesStatus { initial, loading, success, failure }

class ProviderServicesState extends Equatable {
  final ProviderServicesStatus status;
  final List<ServiceModel> allServices;
  final List<ServiceModel> services;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final ServiceSortOption sortOption;
  final String? errorMessage;
  final bool isDeleting;

  const ProviderServicesState({
    this.status = ProviderServicesStatus.initial,
    this.allServices = const [],
    this.services = const [],
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.sortOption = ServiceSortOption.defaultSort,
    this.errorMessage,
    this.isDeleting = false,
  });

  ProviderServicesState copyWith({
    ProviderServicesStatus? status,
    List<ServiceModel>? allServices,
    List<ServiceModel>? services,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    ServiceSortOption? sortOption,
    String? errorMessage,
    bool? isDeleting,
  }) {
    return ProviderServicesState(
      status: status ?? this.status,
      allServices: allServices ?? this.allServices,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allServices,
        services,
        categories,
        selectedCategory,
        searchQuery,
        sortOption,
        errorMessage,
        isDeleting,
      ];
}

import 'package:equatable/equatable.dart';
import '../model/service_model.dart';
import '../widgets/filter_dialog.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final int unreadNotificationsCount;
  final List<String> categories;
  final String selectedCategory;
  final ServiceSortOption sortOption;
  final List<ServiceModel> allServices;
  final List<ServiceModel> featuredServices;
  final List<ServiceModel> filteredServices;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = 'Alex Johnson',
    this.userEmail = 'testuser@example.com',
    this.userAvatar,
    this.unreadNotificationsCount = 0,
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.sortOption = ServiceSortOption.defaultSort,
    this.allServices = const [],
    this.featuredServices = const [],
    this.filteredServices = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? userEmail,
    String? userAvatar,
    int? unreadNotificationsCount,
    List<String>? categories,
    String? selectedCategory,
    ServiceSortOption? sortOption,
    List<ServiceModel>? allServices,
    List<ServiceModel>? featuredServices,
    List<ServiceModel>? filteredServices,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOption: sortOption ?? this.sortOption,
      allServices: allServices ?? this.allServices,
      featuredServices: featuredServices ?? this.featuredServices,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userName,
        userEmail,
        userAvatar,
        unreadNotificationsCount,
        categories,
        selectedCategory,
        sortOption,
        allServices,
        featuredServices,
        filteredServices,
        searchQuery,
        errorMessage,
      ];
}

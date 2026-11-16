import 'package:equatable/equatable.dart';
import '../model/service_model.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final List<String> categories;
  final String selectedCategory;
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
    this.categories = const ['All'],
    this.selectedCategory = 'All',
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
    List<String>? categories,
    String? selectedCategory,
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
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
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
        categories,
        selectedCategory,
        allServices,
        featuredServices,
        filteredServices,
        searchQuery,
        errorMessage,
      ];
}

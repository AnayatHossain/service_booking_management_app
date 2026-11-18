import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import '../model/service_model.dart';
import '../widgets/filter_dialog.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeDataRequested>(_onFetchData);
    on<HomeRefreshed>(_onRefresh);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeSearchChanged>(_onSearchChanged);
    on<HomeFilterApplied>(_onFilterApplied);
    on<HomeFilterReset>(_onFilterReset);
  }

  Future<void> _onFetchData(HomeDataRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    await _loadUserDataAndServices(emit);
  }

  Future<void> _onRefresh(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _loadUserDataAndServices(emit);
  }

  Future<void> _loadUserDataAndServices(Emitter<HomeState> emit) async {
    // 1. Initial cached fallback from SharedPreferences
    String name = await SharedPreferencesHelper.getUserName() ?? 'Customer';
    String email = await SharedPreferencesHelper.getUserEmail() ?? '';
    String? avatar = await SharedPreferencesHelper.getUserAvatar();
    const customerDefaultAvatar =
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';
    if (avatar == null || avatar.isEmpty || !avatar.startsWith('http')) {
      avatar = customerDefaultAvatar;
    }
    int unreadCount = 0;

    final token = await SharedPreferencesHelper.getAccessToken();

    if (token != null) {
      final authHeaders = {'Authorization': 'Bearer $token'};
      // 2. Fetch live user profile from backend
      try {
        final profileApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.profile,
          apiType: ApiType.get,
          apiHeaders: authHeaders,
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final profileRes = await profileApi.call();
        if (profileRes.isSuccess && profileRes.data is Map && profileRes.data['data'] != null) {
          final uData = profileRes.data['data'];
          if (uData['name'] != null && uData['name'].toString().isNotEmpty) {
            name = uData['name'].toString();
            await SharedPreferencesHelper.setUserName(name);
          }
          if (uData['email'] != null && uData['email'].toString().isNotEmpty) {
            email = uData['email'].toString();
            await SharedPreferencesHelper.setUserEmail(email);
          }
          if (uData['avatar_url'] != null && uData['avatar_url'].toString().startsWith('http')) {
            avatar = uData['avatar_url'].toString();
            await SharedPreferencesHelper.setUserAvatar(avatar);
          } else {
            avatar = customerDefaultAvatar;
            await SharedPreferencesHelper.setUserAvatar(avatar);
          }
        }
      } catch (_) {}

      // 3. Fetch unread notifications count
      try {
        final notifApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.unreadNotificationsCount,
          apiType: ApiType.get,
          apiHeaders: authHeaders,
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final notifRes = await notifApi.call();
        if (notifRes.isSuccess && notifRes.data is Map && notifRes.data['data'] != null) {
          unreadCount = notifRes.data['data']['unread_count'] ?? 0;
        }
      } catch (_) {}
    }

    try {
      // 4. Fetch categories
      List<String> catList = ['All'];
      final catApi = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.categories,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final catRes = await catApi.call();
      if (catRes.isSuccess && catRes.data is Map && catRes.data['data'] is List) {
        final List<dynamic> list = catRes.data['data'];
        for (var item in list) {
          final catName = item.toString();
          if (!catList.contains(catName)) {
            catList.add(catName);
          }
        }
      }

      // 5. Fetch all services
      final servicesApi = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.services,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final servicesRes = await servicesApi.call();
      List<ServiceModel> services = [];
      List<ServiceModel> featured = [];

      if (servicesRes.isSuccess && servicesRes.data is Map && servicesRes.data['data'] is List) {
        final List<dynamic> list = servicesRes.data['data'];
        services = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
        featured = services.where((s) => s.isFeatured).toList();
        if (featured.isEmpty && services.isNotEmpty) {
          featured = services.take(3).toList();
        }
      }

      final filtered = _filterAndSortServices(services, state.selectedCategory, state.searchQuery, state.sortOption);

      emit(state.copyWith(
        status: HomeStatus.success,
        userName: name,
        userEmail: email,
        userAvatar: avatar,
        unreadNotificationsCount: unreadCount,
        categories: catList,
        allServices: services,
        featuredServices: featured,
        filteredServices: filtered,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: 'Failed to load services: $e',
      ));
    }
  }

  Future<void> _onCategorySelected(HomeCategorySelected event, Emitter<HomeState> emit) async {
    final filtered = _filterAndSortServices(state.allServices, event.category, state.searchQuery, state.sortOption);
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredServices: filtered,
    ));

    await _fetchFilteredFromBackend(event.category, state.searchQuery, state.sortOption, emit);
  }

  void _onSearchChanged(HomeSearchChanged event, Emitter<HomeState> emit) {
    final filtered = _filterAndSortServices(state.allServices, state.selectedCategory, event.query, state.sortOption);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredServices: filtered,
    ));
  }

  Future<void> _onFilterApplied(HomeFilterApplied event, Emitter<HomeState> emit) async {
    final filtered = _filterAndSortServices(state.allServices, event.category, state.searchQuery, event.sortOption);
    emit(state.copyWith(
      selectedCategory: event.category,
      sortOption: event.sortOption,
      filteredServices: filtered,
    ));

    await _fetchFilteredFromBackend(event.category, state.searchQuery, event.sortOption, emit);
  }

  Future<void> _fetchFilteredFromBackend(
    String category,
    String query,
    ServiceSortOption sortOption,
    Emitter<HomeState> emit,
  ) async {
    String? sortParam;
    switch (sortOption) {
      case ServiceSortOption.priceLowHigh:
        sortParam = 'price_low_high';
        break;
      case ServiceSortOption.priceHighLow:
        sortParam = 'price_high_low';
        break;
      case ServiceSortOption.ratingHigh:
        sortParam = 'rating_high';
        break;
      case ServiceSortOption.defaultSort:
        sortParam = 'recommended';
        break;
    }

    final queryParams = <String>[];
    if (category != 'All' && category.isNotEmpty) {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (query.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(query.trim())}');
    }
    if (sortParam != null) {
      queryParams.add('sort_by=$sortParam');
    }

    final path = queryParams.isEmpty ? Urls.services : '${Urls.services}?${queryParams.join('&')}';

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: path,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final res = await api.call();
      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        final List<dynamic> list = res.data['data'];
        final backendServices = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
        emit(state.copyWith(
          filteredServices: backendServices,
        ));
      }
    } catch (_) {}
  }

  void _onFilterReset(HomeFilterReset event, Emitter<HomeState> emit) {
    final filtered = _filterAndSortServices(state.allServices, 'All', '', ServiceSortOption.defaultSort);
    emit(state.copyWith(
      selectedCategory: 'All',
      searchQuery: '',
      sortOption: ServiceSortOption.defaultSort,
      filteredServices: filtered,
    ));
  }

  List<ServiceModel> _filterAndSortServices(
      List<ServiceModel> list, String category, String query, ServiceSortOption sort) {
    var result = List<ServiceModel>.from(list);

    if (category != 'All' && category.isNotEmpty) {
      result = result
          .where((s) => s.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q))
          .toList();
    }

    switch (sort) {
      case ServiceSortOption.priceLowHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ServiceSortOption.priceHighLow:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ServiceSortOption.ratingHigh:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ServiceSortOption.defaultSort:
        break;
    }

    return result;
  }
}

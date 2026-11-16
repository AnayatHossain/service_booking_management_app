import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services/shared_preferences_helper.dart';
import '../model/service_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeDataRequested>(_onFetchData);
    on<HomeRefreshed>(_onRefresh);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetchData(HomeDataRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await _loadUserDataAndServices(emit);
  }

  Future<void> _onRefresh(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _loadUserDataAndServices(emit);
  }

  Future<void> _loadUserDataAndServices(Emitter<HomeState> emit) async {
    // 1. Load User Info from SharedPreferences
    final name = await SharedPreferencesHelper.getUserName() ?? 'Alex Johnson';
    final email = await SharedPreferencesHelper.getUserEmail() ?? 'testuser@example.com';
    final avatar = await SharedPreferencesHelper.getUserAvatar();

    try {
      // 2. Fetch categories
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

      // 3. Fetch all services
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

      final filtered = _filterServices(services, state.selectedCategory, state.searchQuery);

      emit(state.copyWith(
        status: HomeStatus.success,
        userName: name,
        userEmail: email,
        userAvatar: avatar,
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

  void _onCategorySelected(HomeCategorySelected event, Emitter<HomeState> emit) {
    final filtered = _filterServices(state.allServices, event.category, state.searchQuery);
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredServices: filtered,
    ));
  }

  void _onSearchChanged(HomeSearchChanged event, Emitter<HomeState> emit) {
    final filtered = _filterServices(state.allServices, state.selectedCategory, event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredServices: filtered,
    ));
  }

  List<ServiceModel> _filterServices(
      List<ServiceModel> list, String category, String query) {
    var result = list;
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
    return result;
  }
}

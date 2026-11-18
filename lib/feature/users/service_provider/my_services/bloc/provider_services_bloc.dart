import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../../core/network_caller/endpoints.dart';
import '../../../normal_user/home_screen/model/service_model.dart';
import '../../../normal_user/home_screen/widgets/filter_dialog.dart';
import 'provider_services_event.dart';
import 'provider_services_state.dart';

class ProviderServicesBloc extends Bloc<ProviderServicesEvent, ProviderServicesState> {
  ProviderServicesBloc() : super(const ProviderServicesState()) {
    on<ProviderServicesFetchRequested>(_onFetchRequested);
    on<ProviderServiceDeleteRequested>(_onDeleteRequested);
    on<ProviderServiceOptimisticAddOrUpdate>(_onAddOrUpdate);
    on<ProviderServicesSearchChanged>(_onSearchChanged);
    on<ProviderServicesFilterApplied>(_onFilterApplied);
    on<ProviderServicesFilterReset>(_onFilterReset);
  }

  Future<void> _onFetchRequested(
    ProviderServicesFetchRequested event,
    Emitter<ProviderServicesState> emit,
  ) async {
    emit(state.copyWith(status: ProviderServicesStatus.loading));
    final token = await Urls.bearerToken;

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerServices,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final res = await api.call();

      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        final List<dynamic> rawList = res.data['data'];
        final services = rawList
            .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        final Set<String> catSet = {'All'};
        for (final s in services) {
          if (s.category.isNotEmpty) catSet.add(s.category);
        }

        final filtered = _filterAndSortServices(services, state.selectedCategory, state.searchQuery, state.sortOption);

        emit(state.copyWith(
          status: ProviderServicesStatus.success,
          allServices: services,
          services: filtered,
          categories: catSet.toList(),
        ));
      } else {
        // Fallback to all services if provider endpoint returns empty
        final fallbackApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.services,
          apiType: ApiType.get,
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final fallbackRes = await fallbackApi.call();
        if (fallbackRes.isSuccess && fallbackRes.data is Map && fallbackRes.data['data'] is List) {
          final List<dynamic> rawList = fallbackRes.data['data'];
          final services = rawList
              .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();

          final Set<String> catSet = {'All'};
          for (final s in services) {
            if (s.category.isNotEmpty) catSet.add(s.category);
          }

          final filtered = _filterAndSortServices(services, state.selectedCategory, state.searchQuery, state.sortOption);

          emit(state.copyWith(
            status: ProviderServicesStatus.success,
            allServices: services,
            services: filtered,
            categories: catSet.toList(),
          ));
        } else {
          emit(state.copyWith(
            status: ProviderServicesStatus.failure,
            errorMessage: res.message ?? 'Failed to load services',
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProviderServicesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchChanged(
    ProviderServicesSearchChanged event,
    Emitter<ProviderServicesState> emit,
  ) async {
    final filtered = _filterAndSortServices(
      state.allServices,
      state.selectedCategory,
      event.query,
      state.sortOption,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      services: filtered,
    ));

    await _fetchFilteredFromBackend(
      state.selectedCategory,
      event.query,
      state.sortOption,
      emit,
    );
  }

  Future<void> _onFilterApplied(
    ProviderServicesFilterApplied event,
    Emitter<ProviderServicesState> emit,
  ) async {
    final sort = event.sortOption is ServiceSortOption
        ? event.sortOption as ServiceSortOption
        : state.sortOption;

    final filtered = _filterAndSortServices(
      state.allServices,
      event.category,
      state.searchQuery,
      sort,
    );
    emit(state.copyWith(
      selectedCategory: event.category,
      sortOption: sort,
      services: filtered,
    ));

    await _fetchFilteredFromBackend(
      event.category,
      state.searchQuery,
      sort,
      emit,
    );
  }

  Future<void> _onFilterReset(
    ProviderServicesFilterReset event,
    Emitter<ProviderServicesState> emit,
  ) async {
    final filtered = _filterAndSortServices(
      state.allServices,
      'All',
      '',
      ServiceSortOption.defaultSort,
    );
    emit(state.copyWith(
      selectedCategory: 'All',
      searchQuery: '',
      sortOption: ServiceSortOption.defaultSort,
      services: filtered,
    ));

    await _fetchFilteredFromBackend(
      'All',
      '',
      ServiceSortOption.defaultSort,
      emit,
    );
  }

  List<ServiceModel> _filterAndSortServices(
    List<ServiceModel> source,
    String category,
    String query,
    ServiceSortOption sortOption,
  ) {
    var list = source.where((s) {
      final matchesCategory = (category == 'All' || s.category.toLowerCase() == category.toLowerCase());
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    switch (sortOption) {
      case ServiceSortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ServiceSortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ServiceSortOption.ratingHigh:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ServiceSortOption.defaultSort:
        list.sort((a, b) {
          if (a.isFeatured != b.isFeatured) {
            return a.isFeatured ? -1 : 1;
          }
          return b.rating.compareTo(a.rating);
        });
        break;
    }
    return list;
  }

  Future<void> _fetchFilteredFromBackend(
    String category,
    String query,
    ServiceSortOption sortOption,
    Emitter<ProviderServicesState> emit,
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

    final path = queryParams.isEmpty ? Urls.providerServices : '${Urls.providerServices}?${queryParams.join('&')}';

    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: path,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final res = await api.call();
      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        final List<dynamic> list = res.data['data'];
        final backendServices = list.map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        emit(state.copyWith(
          services: backendServices,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onDeleteRequested(
    ProviderServiceDeleteRequested event,
    Emitter<ProviderServicesState> emit,
  ) async {
    // Optimistic UI removal
    final updatedList = state.services.where((s) => s.id != event.serviceId).toList();
    final updatedAll = state.allServices.where((s) => s.id != event.serviceId).toList();
    emit(state.copyWith(services: updatedList, allServices: updatedAll, isDeleting: true));

    final token = await Urls.bearerToken;
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerDeleteService(event.serviceId),
        apiType: ApiType.delete,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      await api.call();
    } catch (_) {}

    emit(state.copyWith(isDeleting: false));
  }

  void _onAddOrUpdate(
    ProviderServiceOptimisticAddOrUpdate event,
    Emitter<ProviderServicesState> emit,
  ) {
    final all = List<ServiceModel>.from(state.allServices);
    final idx = all.indexWhere((s) => s.id == event.service.id);
    if (idx != -1) {
      all[idx] = event.service;
    } else {
      all.insert(0, event.service);
    }
    final filtered = _filterAndSortServices(all, state.selectedCategory, state.searchQuery, state.sortOption);
    emit(state.copyWith(allServices: all, services: filtered));
  }
}

import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../model/service_model.dart';

class HomeController extends GetxController {
  var services = <ServiceModel>[].obs;
  var featuredServices = <ServiceModel>[].obs;
  var categories = <String>['All'].obs;
  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  var isLoading = false.obs;
  var isFeaturedLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllHomeData();
  }

  Future<void> fetchAllHomeData() async {
    await Future.wait([
      fetchCategories(),
      fetchFeaturedServices(),
      fetchServices(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.categories,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> catList = response.data['data'];
        categories.value = catList.map((e) => e.toString()).toList();
      }
    } catch (_) {}
  }

  Future<void> fetchFeaturedServices() async {
    try {
      isFeaturedLoading.value = true;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.featuredServices,
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        featuredServices.value = list.map((item) => ServiceModel.fromJson(item)).toList();
      }
    } catch (_) {
    } finally {
      isFeaturedLoading.value = false;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, String> params = {};
      if (searchQuery.value.trim().isNotEmpty) {
        params['search'] = searchQuery.value.trim();
      }
      if (selectedCategory.value != 'All') {
        params['category'] = selectedCategory.value;
      }

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.services,
        apiType: ApiType.get,
        apiParams: params.isNotEmpty ? ApiParams.simple(params) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();
      if (response.isSuccess && response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        services.value = list.map((item) => ServiceModel.fromJson(item)).toList();
      } else {
        errorMessage.value = response.data?['message'] ?? 'Failed to load services';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load services: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onCategorySelected(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchServices();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Debounce can be added or simple fetch
    fetchServices();
  }

  void clearSearch() {
    searchQuery.value = '';
    fetchServices();
  }
}

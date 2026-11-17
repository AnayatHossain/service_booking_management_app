import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';

class ServiceDetailsController extends GetxController {
  final String serviceId;
  ServiceDetailsController({required this.serviceId});

  var service = Rxn<ServiceModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.serviceDetails(serviceId),
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data['data'] != null) {
        service.value = ServiceModel.fromJson(response.data['data']);
      } else {
        errorMessage.value = response.data?['message'] ?? 'Service not found';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load details: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../normal_user/home_screen/model/service_model.dart';
import '../screens/provider_add_edit_service_screen.dart';
import '../screens/provider_service_details_screen.dart';
import '../widgets/provider_delete_service_dialog.dart';

class ProviderServicesController {
  static Future<ServiceModel?> navigateToAddService(BuildContext context) async {
    final result = await Get.to(() => const ProviderAddEditServiceScreen());
    if (result != null && result is ServiceModel) {
      return result;
    }
    return null;
  }

  static Future<ServiceModel?> navigateToEditService(
    BuildContext context,
    ServiceModel service,
  ) async {
    final result = await Get.to(() => ProviderAddEditServiceScreen(service: service));
    if (result != null && result is ServiceModel) {
      return result;
    }
    return null;
  }

  static Future<void> navigateToDetails(
    BuildContext context,
    ServiceModel service, {
    VoidCallback? onUpdated,
    VoidCallback? onDeleted,
  }) async {
    await Get.to(() => ProviderServiceDetailsScreen(
          service: service,
          onServiceUpdated: onUpdated,
          onServiceDeleted: onDeleted,
        ));
  }

  static Future<bool?> confirmDelete(
    BuildContext context, {
    required String serviceName,
  }) async {
    return await ProviderDeleteServiceDialog.show(
      context,
      serviceName: serviceName,
    );
  }
}

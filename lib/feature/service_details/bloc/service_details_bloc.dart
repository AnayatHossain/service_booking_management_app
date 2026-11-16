import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import 'service_details_event.dart';
import 'service_details_state.dart';

class ServiceDetailsBloc
    extends Bloc<ServiceDetailsEvent, ServiceDetailsState> {
  final ServiceModel? initialService;

  ServiceDetailsBloc({this.initialService})
      : super(ServiceDetailsState(
          status: initialService != null
              ? ServiceDetailsStatus.success
              : ServiceDetailsStatus.initial,
          service: initialService,
        )) {
    on<ServiceDetailsFetchRequested>(_onFetchDetails);
  }

  Future<void> _onFetchDetails(
      ServiceDetailsFetchRequested event, Emitter<ServiceDetailsState> emit) async {
    emit(state.copyWith(status: ServiceDetailsStatus.loading, errorMessage: null));

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.serviceDetails(event.serviceId),
        apiType: ApiType.get,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final service = ServiceModel.fromJson(response.data['data']);
        emit(state.copyWith(
          status: ServiceDetailsStatus.success,
          service: service,
        ));
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Service details not found.';
        emit(state.copyWith(
          status: ServiceDetailsStatus.failure,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ServiceDetailsStatus.failure,
        errorMessage: 'Failed to load details: $e',
      ));
    }
  }
}

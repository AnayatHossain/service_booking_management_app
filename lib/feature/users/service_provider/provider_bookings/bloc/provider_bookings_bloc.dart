import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../../core/events/booking_event_bus.dart';
import '../../../../../core/network_caller/endpoints.dart';
import '../../../normal_user/my_bookings/model/booking_model.dart';
import 'provider_bookings_event.dart';
import 'provider_bookings_state.dart';

class ProviderBookingsBloc extends Bloc<ProviderBookingsEvent, ProviderBookingsState> {
  ProviderBookingsBloc() : super(const ProviderBookingsState()) {
    on<ProviderBookingsFetchRequested>(_onFetchRequested);
    on<ProviderBookingsTabChanged>(_onTabChanged);
    on<ProviderBookingStatusUpdateRequested>(_onStatusUpdateRequested);
    on<ProviderBookingStatusUpdated>(_onStatusUpdated);
  }

  Future<void> _onFetchRequested(
    ProviderBookingsFetchRequested event,
    Emitter<ProviderBookingsState> emit,
  ) async {
    if (!event.silent) {
      emit(state.copyWith(status: ProviderBookingsStatus.loading));
    }

    final token = await Urls.bearerToken;
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerBookings,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final res = await api.call();

      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        final List<dynamic> raw = res.data['data'];
        final bookings = raw
            .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        emit(state.copyWith(
          status: ProviderBookingsStatus.success,
          allBookings: bookings,
        ));
      } else {
        emit(state.copyWith(
          status: ProviderBookingsStatus.failure,
          errorMessage: res.message ?? 'Failed to load bookings',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProviderBookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTabChanged(
    ProviderBookingsTabChanged event,
    Emitter<ProviderBookingsState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tabIndex));
  }

  void _onStatusUpdated(
    ProviderBookingStatusUpdated event,
    Emitter<ProviderBookingsState> emit,
  ) {
    final updatedList = state.allBookings.map((b) {
      if (b.id == event.bookingId) {
        return b.copyWith(status: event.newStatus);
      }
      return b;
    }).toList();
    emit(state.copyWith(allBookings: updatedList));
  }

  Future<void> _onStatusUpdateRequested(
    ProviderBookingStatusUpdateRequested event,
    Emitter<ProviderBookingsState> emit,
  ) async {
    // 1. Optimistic update
    final updatedList = state.allBookings.map((b) {
      if (b.id == event.bookingId) {
        return b.copyWith(status: event.newStatus);
      }
      return b;
    }).toList();

    emit(state.copyWith(allBookings: updatedList, isUpdating: true));

    // 2. Broadcast globally
    BookingEventBus.notifyStatusChanged(
      bookingId: event.bookingId,
      newStatus: event.newStatus,
    );

    // 3. Network call
    final token = await Urls.bearerToken;
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerUpdateBookingStatus(event.bookingId, event.newStatus),
        apiType: ApiType.patch,
        apiHeaders: {'Authorization': token},
        enableLoading: true,
        enableApiSuccessResponseGetSnackBar: true,
        enableApiErrorResponseGetSnackBar: true,
      );
      await api.call();
    } catch (_) {}

    emit(state.copyWith(isUpdating: false));
  }
}

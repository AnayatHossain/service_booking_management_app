import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../model/booking_model.dart';
import 'my_bookings_event.dart';
import 'my_bookings_state.dart';

class MyBookingsBloc extends Bloc<MyBookingsEvent, MyBookingsState> {
  MyBookingsBloc() : super(const MyBookingsState()) {
    on<MyBookingsFetchRequested>(_onFetchBookings);
    on<MyBookingsFilterChanged>(_onFilterChanged);
    on<MyBookingsCancelRequested>(_onCancelBooking);

    add(const MyBookingsFetchRequested());
  }

  Future<void> _onFetchBookings(
      MyBookingsFetchRequested event, Emitter<MyBookingsState> emit) async {
    emit(state.copyWith(status: MyBookingsStatus.loading, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.myAppointments,
        apiType: ApiType.get,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] is List) {
        final List<dynamic> list = response.data['data'];
        final bookings = list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
        final filtered = _filterByTab(bookings, state.selectedTab);

        emit(state.copyWith(
          status: MyBookingsStatus.success,
          allBookings: bookings,
          filteredBookings: filtered,
        ));
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Failed to load bookings.';
        emit(state.copyWith(
          status: MyBookingsStatus.failure,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: MyBookingsStatus.failure,
        errorMessage: 'Network error: $e',
      ));
    }
  }

  void _onFilterChanged(
      MyBookingsFilterChanged event, Emitter<MyBookingsState> emit) {
    final filtered = _filterByTab(state.allBookings, event.tabIndex);
    emit(state.copyWith(
      selectedTab: event.tabIndex,
      filteredBookings: filtered,
    ));
  }

  Future<void> _onCancelBooking(
      MyBookingsCancelRequested event, Emitter<MyBookingsState> emit) async {
    emit(state.copyWith(isCancelling: true, errorMessage: null, successMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.cancelAppointment(event.appointmentId),
        apiType: ApiType.patch,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        emit(state.copyWith(
          isCancelling: false,
          successMessage: 'Appointment cancelled successfully.',
        ));
        add(const MyBookingsFetchRequested());
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Failed to cancel appointment.';
        emit(state.copyWith(
          isCancelling: false,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isCancelling: false,
        errorMessage: 'Cancellation failed: $e',
      ));
    }
  }

  List<BookingModel> _filterByTab(List<BookingModel> list, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return list.where((b) => b.isPending).toList();
      case 2:
        return list.where((b) => b.isConfirmed).toList();
      case 3:
        return list.where((b) => b.isCompleted).toList();
      case 4:
        return list.where((b) => b.isCancelled).toList();
      default:
        return list;
    }
  }
}

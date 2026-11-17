import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../../home_screen/model/service_model.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final ServiceModel service;

  AppointmentBloc({required this.service})
      : super(AppointmentState(
          selectedDate: DateTime.now().add(const Duration(days: 1)),
        )) {
    on<AppointmentDateChanged>(_onDateChanged);
    on<AppointmentSlotSelected>(_onSlotSelected);
    on<AppointmentFetchSlots>(_onFetchSlots);
    on<AppointmentSubmitRequested>(_onSubmit);

    add(const AppointmentFetchSlots());
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(state.selectedDate);

  void _onDateChanged(
      AppointmentDateChanged event, Emitter<AppointmentState> emit) {
    emit(state.copyWith(
      selectedDate: event.date,
      selectedTimeSlot: null,
      slotWarning: null,
    ));
    add(const AppointmentFetchSlots());
  }

  void _onSlotSelected(
      AppointmentSlotSelected event, Emitter<AppointmentState> emit) {
    if (!event.isAvailable) {
      emit(state.copyWith(
        slotWarning: 'This time slot is already booked. Please choose another.',
      ));
      return;
    }
    emit(state.copyWith(
      selectedTimeSlot: event.slot,
      slotWarning: null,
    ));
  }

  Future<void> _onFetchSlots(
      AppointmentFetchSlots event, Emitter<AppointmentState> emit) async {
    emit(state.copyWith(isLoadingSlots: true, errorMessage: null, slotWarning: null));

    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.checkAvailability,
        apiType: ApiType.get,
        apiParams: ApiParams.simple({
          'service_id': service.id,
          'date': _formattedDate,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] != null) {
        final List<dynamic> rawSlots = response.data['data']['slots'] ?? [];
        final slots = rawSlots.map((s) => AppointmentSlotInfo(
          slot: s['slot'].toString(),
          isAvailable: s['is_available'] == true,
        )).toList();

        // Auto-select first available slot if not selected
        String? selected = state.selectedTimeSlot;
        if (selected == null || !slots.any((s) => s.slot == selected && s.isAvailable)) {
          final first = slots.where((s) => s.isAvailable).firstOrNull;
          selected = first?.slot;
        }

        emit(state.copyWith(
          isLoadingSlots: false,
          slots: slots,
          selectedTimeSlot: selected,
        ));
      } else {
        // Fallback to service's defined time slots
        final slots = service.timeSlots
            .map((s) => AppointmentSlotInfo(slot: s, isAvailable: true))
            .toList();
        emit(state.copyWith(
          isLoadingSlots: false,
          slots: slots,
          selectedTimeSlot: state.selectedTimeSlot ?? slots.firstOrNull?.slot,
        ));
      }
    } catch (_) {
      final slots = service.timeSlots
          .map((s) => AppointmentSlotInfo(slot: s, isAvailable: true))
          .toList();
      emit(state.copyWith(
        isLoadingSlots: false,
        slots: slots,
        selectedTimeSlot: state.selectedTimeSlot ?? slots.firstOrNull?.slot,
      ));
    }
  }

  Future<void> _onSubmit(
      AppointmentSubmitRequested event, Emitter<AppointmentState> emit) async {
    if (state.selectedTimeSlot == null) {
      emit(state.copyWith(
        status: AppointmentStatus.failure,
        errorMessage: 'Please select an available time slot.',
      ));
      return;
    }

    emit(state.copyWith(isBooking: true, errorMessage: null));

    try {
      final token = await Urls.rawToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.appointments,
        apiType: ApiType.post,
        apiAuthorization: token != null ? ApiAuthorization.bearer(token) : null,
        apiBody: ApiBody.json({
          'service_id': service.id,
          'appointment_date': _formattedDate,
          'time_slot': state.selectedTimeSlot,
          'customer_notes': event.notes.trim().isNotEmpty ? event.notes.trim() : null,
        }),
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess) {
        final resData = response.data;
        if (resData is Map && resData['success'] == true && resData['data'] != null) {
          emit(state.copyWith(
            status: AppointmentStatus.success,
            isBooking: false,
            bookingConfirmation: resData['data'] as Map<String, dynamic>,
          ));
        } else {
          final msg = (resData is Map && resData['message'] != null)
              ? resData['message']
              : 'Failed to create booking. Please try again.';
          emit(state.copyWith(
            status: AppointmentStatus.failure,
            isBooking: false,
            errorMessage: msg,
          ));
        }
      } else {
        final msg = response.errorMessage ??
            (response.data is Map ? response.data['message'] : null) ??
            'Booking failed. (Status: ${response.statusCode})';
        emit(state.copyWith(
          status: AppointmentStatus.failure,
          isBooking: false,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.failure,
        isBooking: false,
        errorMessage: 'Network error: $e',
      ));
    }
  }
}

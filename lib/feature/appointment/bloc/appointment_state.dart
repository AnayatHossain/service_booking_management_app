import 'package:equatable/equatable.dart';

enum AppointmentStatus { initial, loading, success, failure }

class AppointmentSlotInfo extends Equatable {
  final String slot;
  final bool isAvailable;

  const AppointmentSlotInfo({required this.slot, required this.isAvailable});

  @override
  List<Object?> get props => [slot, isAvailable];
}

class AppointmentState extends Equatable {
  final AppointmentStatus status;
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final List<AppointmentSlotInfo> slots;
  final bool isLoadingSlots;
  final bool isBooking;
  final Map<String, dynamic>? bookingConfirmation;
  final String? errorMessage;
  final String? slotWarning;

  const AppointmentState({
    this.status = AppointmentStatus.initial,
    required this.selectedDate,
    this.selectedTimeSlot,
    this.slots = const [],
    this.isLoadingSlots = false,
    this.isBooking = false,
    this.bookingConfirmation,
    this.errorMessage,
    this.slotWarning,
  });

  AppointmentState copyWith({
    AppointmentStatus? status,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    List<AppointmentSlotInfo>? slots,
    bool? isLoadingSlots,
    bool? isBooking,
    Map<String, dynamic>? bookingConfirmation,
    String? errorMessage,
    String? slotWarning,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      slots: slots ?? this.slots,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isBooking: isBooking ?? this.isBooking,
      bookingConfirmation: bookingConfirmation ?? this.bookingConfirmation,
      errorMessage: errorMessage,
      slotWarning: slotWarning,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedDate,
        selectedTimeSlot,
        slots,
        isLoadingSlots,
        isBooking,
        bookingConfirmation,
        errorMessage,
        slotWarning,
      ];
}

import 'package:equatable/equatable.dart';
import '../model/booking_model.dart';

enum MyBookingsStatus { initial, loading, success, failure }

class MyBookingsState extends Equatable {
  final MyBookingsStatus status;
  final int selectedTab;
  final List<BookingModel> allBookings;
  final List<BookingModel> filteredBookings;
  final bool isCancelling;
  final String? errorMessage;
  final String? successMessage;

  const MyBookingsState({
    this.status = MyBookingsStatus.initial,
    this.selectedTab = 0,
    this.allBookings = const [],
    this.filteredBookings = const [],
    this.isCancelling = false,
    this.errorMessage,
    this.successMessage,
  });

  MyBookingsState copyWith({
    MyBookingsStatus? status,
    int? selectedTab,
    List<BookingModel>? allBookings,
    List<BookingModel>? filteredBookings,
    bool? isCancelling,
    String? errorMessage,
    String? successMessage,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      allBookings: allBookings ?? this.allBookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      isCancelling: isCancelling ?? this.isCancelling,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        allBookings,
        filteredBookings,
        isCancelling,
        errorMessage,
        successMessage,
      ];
}

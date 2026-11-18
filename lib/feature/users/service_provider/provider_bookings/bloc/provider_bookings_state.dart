import 'package:equatable/equatable.dart';
import '../../../normal_user/my_bookings/model/booking_model.dart';

enum ProviderBookingsStatus { initial, loading, success, failure }

class ProviderBookingsState extends Equatable {
  final ProviderBookingsStatus status;
  final List<BookingModel> allBookings;
  final int selectedTab;
  final String? errorMessage;
  final bool isUpdating;

  const ProviderBookingsState({
    this.status = ProviderBookingsStatus.initial,
    this.allBookings = const [],
    this.selectedTab = 0,
    this.errorMessage,
    this.isUpdating = false,
  });

  static const List<String> tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  List<BookingModel> get filteredBookings {
    if (selectedTab == 0) return allBookings;
    final tabName = tabs[selectedTab].toLowerCase();
    return allBookings.where((b) => b.status.toLowerCase() == tabName).toList();
  }

  ProviderBookingsState copyWith({
    ProviderBookingsStatus? status,
    List<BookingModel>? allBookings,
    int? selectedTab,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return ProviderBookingsState(
      status: status ?? this.status,
      allBookings: allBookings ?? this.allBookings,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage ?? this.errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [status, allBookings, selectedTab, errorMessage, isUpdating];
}

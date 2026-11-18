import 'package:equatable/equatable.dart';

abstract class ProviderBookingsEvent extends Equatable {
  const ProviderBookingsEvent();

  @override
  List<Object?> get props => [];
}

class ProviderBookingsFetchRequested extends ProviderBookingsEvent {
  final bool silent;
  const ProviderBookingsFetchRequested({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

class ProviderBookingsTabChanged extends ProviderBookingsEvent {
  final int tabIndex;
  const ProviderBookingsTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ProviderBookingStatusUpdateRequested extends ProviderBookingsEvent {
  final String bookingId;
  final String newStatus;
  const ProviderBookingStatusUpdateRequested({required this.bookingId, required this.newStatus});

  @override
  List<Object?> get props => [bookingId, newStatus];
}

class ProviderBookingStatusUpdated extends ProviderBookingsEvent {
  final String bookingId;
  final String newStatus;
  const ProviderBookingStatusUpdated({required this.bookingId, required this.newStatus});

  @override
  List<Object?> get props => [bookingId, newStatus];
}

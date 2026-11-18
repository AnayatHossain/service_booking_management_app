import 'package:equatable/equatable.dart';

abstract class ProviderDashboardEvent extends Equatable {
  const ProviderDashboardEvent();

  @override
  List<Object?> get props => [];
}

class ProviderDashboardFetchRequested extends ProviderDashboardEvent {
  final bool silent;
  const ProviderDashboardFetchRequested({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

class ProviderDashboardBookingStatusUpdated extends ProviderDashboardEvent {
  final String bookingId;
  final String newStatus;
  const ProviderDashboardBookingStatusUpdated({required this.bookingId, required this.newStatus});

  @override
  List<Object?> get props => [bookingId, newStatus];
}

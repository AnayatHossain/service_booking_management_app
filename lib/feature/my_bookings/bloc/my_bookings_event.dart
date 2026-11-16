import 'package:equatable/equatable.dart';

abstract class MyBookingsEvent extends Equatable {
  const MyBookingsEvent();

  @override
  List<Object?> get props => [];
}

class MyBookingsFetchRequested extends MyBookingsEvent {
  const MyBookingsFetchRequested();
}

class MyBookingsFilterChanged extends MyBookingsEvent {
  final int tabIndex; // 0: All, 1: Pending, 2: Confirmed, 3: Completed, 4: Cancelled
  const MyBookingsFilterChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class MyBookingsCancelRequested extends MyBookingsEvent {
  final String appointmentId;
  const MyBookingsCancelRequested(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

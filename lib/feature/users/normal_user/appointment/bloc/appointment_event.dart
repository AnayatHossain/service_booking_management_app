import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentDateChanged extends AppointmentEvent {
  final DateTime date;
  const AppointmentDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class AppointmentSlotSelected extends AppointmentEvent {
  final String slot;
  final bool isAvailable;
  const AppointmentSlotSelected(this.slot, this.isAvailable);

  @override
  List<Object?> get props => [slot, isAvailable];
}

class AppointmentFetchSlots extends AppointmentEvent {
  const AppointmentFetchSlots();
}

class AppointmentSubmitRequested extends AppointmentEvent {
  final String notes;
  const AppointmentSubmitRequested({this.notes = ''});

  @override
  List<Object?> get props => [notes];
}

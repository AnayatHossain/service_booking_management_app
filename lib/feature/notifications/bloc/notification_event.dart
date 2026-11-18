import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationFetchRequested extends NotificationEvent {
  const NotificationFetchRequested();
}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final String id;
  const NotificationMarkAsReadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {
  const NotificationMarkAllAsReadRequested();
}

class NotificationDeleteRequested extends NotificationEvent {
  final String id;
  const NotificationDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

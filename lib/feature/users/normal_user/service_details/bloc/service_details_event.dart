import 'package:equatable/equatable.dart';

abstract class ServiceDetailsEvent extends Equatable {
  const ServiceDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ServiceDetailsFetchRequested extends ServiceDetailsEvent {
  final String serviceId;
  const ServiceDetailsFetchRequested(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

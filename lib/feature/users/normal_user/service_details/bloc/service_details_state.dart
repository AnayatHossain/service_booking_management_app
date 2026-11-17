import 'package:equatable/equatable.dart';
import '../../home_screen/model/service_model.dart';

enum ServiceDetailsStatus { initial, loading, success, failure }

class ServiceDetailsState extends Equatable {
  final ServiceDetailsStatus status;
  final ServiceModel? service;
  final String? errorMessage;

  const ServiceDetailsState({
    this.status = ServiceDetailsStatus.initial,
    this.service,
    this.errorMessage,
  });

  ServiceDetailsState copyWith({
    ServiceDetailsStatus? status,
    ServiceModel? service,
    String? errorMessage,
  }) {
    return ServiceDetailsState(
      status: status ?? this.status,
      service: service ?? this.service,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, service, errorMessage];
}

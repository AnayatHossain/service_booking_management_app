import 'package:equatable/equatable.dart';
import '../../../normal_user/home_screen/model/service_model.dart';

abstract class ProviderServicesEvent extends Equatable {
  const ProviderServicesEvent();

  @override
  List<Object?> get props => [];
}

class ProviderServicesFetchRequested extends ProviderServicesEvent {
  const ProviderServicesFetchRequested();
}

class ProviderServiceDeleteRequested extends ProviderServicesEvent {
  final String serviceId;
  const ProviderServiceDeleteRequested(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ProviderServiceOptimisticAddOrUpdate extends ProviderServicesEvent {
  final ServiceModel service;
  const ProviderServiceOptimisticAddOrUpdate(this.service);

  @override
  List<Object?> get props => [service];
}

class ProviderServicesSearchChanged extends ProviderServicesEvent {
  final String query;
  const ProviderServicesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProviderServicesFilterApplied extends ProviderServicesEvent {
  final String category;
  final dynamic sortOption;
  const ProviderServicesFilterApplied({
    required this.category,
    required this.sortOption,
  });

  @override
  List<Object?> get props => [category, sortOption];
}

class ProviderServicesFilterReset extends ProviderServicesEvent {
  const ProviderServicesFilterReset();
}

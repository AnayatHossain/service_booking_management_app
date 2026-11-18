import 'package:equatable/equatable.dart';
import '../model/provider_dashboard_model.dart';

enum ProviderDashboardStatus { initial, loading, success, failure }

class ProviderDashboardState extends Equatable {
  final ProviderDashboardStatus status;
  final ProviderDashboardModel dashboardData;
  final String? errorMessage;

  const ProviderDashboardState({
    this.status = ProviderDashboardStatus.initial,
    this.dashboardData = const ProviderDashboardModel(),
    this.errorMessage,
  });

  ProviderDashboardState copyWith({
    ProviderDashboardStatus? status,
    ProviderDashboardModel? dashboardData,
    String? errorMessage,
  }) {
    return ProviderDashboardState(
      status: status ?? this.status,
      dashboardData: dashboardData ?? this.dashboardData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboardData, errorMessage];
}

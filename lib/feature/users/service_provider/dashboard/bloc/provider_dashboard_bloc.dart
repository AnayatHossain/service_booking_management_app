import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import '../../../../../core/network_caller/endpoints.dart';
import '../../../../../core/services/shared_preferences_helper.dart';
import '../model/provider_dashboard_model.dart';
import 'provider_dashboard_event.dart';
import 'provider_dashboard_state.dart';

class ProviderDashboardBloc extends Bloc<ProviderDashboardEvent, ProviderDashboardState> {
  ProviderDashboardBloc() : super(const ProviderDashboardState()) {
    on<ProviderDashboardFetchRequested>(_onFetchRequested);
    on<ProviderDashboardBookingStatusUpdated>(_onStatusUpdated);
  }

  Future<void> _onFetchRequested(
    ProviderDashboardFetchRequested event,
    Emitter<ProviderDashboardState> emit,
  ) async {
    if (!event.silent) {
      emit(state.copyWith(status: ProviderDashboardStatus.loading));
    }

    try {
      final token = await Urls.bearerToken;
      final savedName = await SharedPreferencesHelper.getUserName();
      final savedOrg = await SharedPreferencesHelper.getInstitutionName();
      final savedAvatar = await SharedPreferencesHelper.getAvatarUrl();

      String pName = (savedName != null && savedName.isNotEmpty) ? savedName : 'Apex Pro Services';
      String instName = (savedOrg != null && savedOrg.isNotEmpty) ? savedOrg : '';
      String? aUrl = savedAvatar;
      int unread = 0;
      int totalSrv = 0;
      int totalBk = 0;
      int pendingBk = 0;
      int completedBk = 0;
      List<dynamic> recentBk = [];

      // 1. Profile API
      try {
        final profileApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.profile,
          apiType: ApiType.get,
          apiHeaders: {'Authorization': token},
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final res = await profileApi.call();
        if (res.isSuccess && res.data is Map && res.data['data'] is Map) {
          final u = res.data['data'] as Map;
          pName = (u['name'] != null && u['name'].toString().isNotEmpty) ? u['name'] : pName;
          final backendOrg = u['institution_name'] ?? u['organization_name'];
          if (backendOrg != null && backendOrg.toString().isNotEmpty) {
            instName = backendOrg.toString();
          }
          if (u['avatar_url'] != null && u['avatar_url'].toString().isNotEmpty) {
            aUrl = u['avatar_url'];
          }
        }
      } catch (_) {}

      // 2. Services count
      try {
        final srvApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.providerServices,
          apiType: ApiType.get,
          apiHeaders: {'Authorization': token},
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final res = await srvApi.call();
        if (res.isSuccess && res.data is Map && res.data['data'] is List) {
          totalSrv = (res.data['data'] as List).length;
        }
      } catch (_) {}

      // 3. Bookings
      try {
        final bkApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.providerBookings,
          apiType: ApiType.get,
          apiHeaders: {'Authorization': token},
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final res = await bkApi.call();
        if (res.isSuccess && res.data is Map && res.data['data'] is List) {
          final List<dynamic> allBk = res.data['data'];
          totalBk = allBk.length;
          pendingBk = allBk.where((b) => (b['status'] ?? '').toString().toLowerCase() == 'pending').length;
          completedBk = allBk.where((b) => (b['status'] ?? '').toString().toLowerCase() == 'completed').length;
          recentBk = allBk.take(6).toList();
        }
      } catch (_) {}

      // 4. Unread count
      try {
        final unreadApi = FlutterApiCraft(
          baseUrl: Urls.baseUrl,
          path: Urls.unreadNotificationsCount,
          apiType: ApiType.get,
          apiHeaders: {'Authorization': token},
          enableLoading: false,
          enableApiSuccessResponseGetSnackBar: false,
          enableApiErrorResponseGetSnackBar: false,
        );
        final res = await unreadApi.call();
        if (res.isSuccess && res.data is Map && res.data['data'] is Map) {
          unread = res.data['data']['unread_count'] ?? 0;
        }
      } catch (_) {}

      emit(state.copyWith(
        status: ProviderDashboardStatus.success,
        dashboardData: ProviderDashboardModel(
          providerName: pName,
          institutionName: instName,
          avatarUrl: aUrl,
          totalServices: totalSrv,
          totalBookings: totalBk,
          pendingBookings: pendingBk,
          completedBookings: completedBk,
          unreadCount: unread,
          recentBookings: recentBk,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProviderDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStatusUpdated(
    ProviderDashboardBookingStatusUpdated event,
    Emitter<ProviderDashboardState> emit,
  ) {
    final cur = state.dashboardData;
    final list = List<dynamic>.from(cur.recentBookings);
    int pCount = cur.pendingBookings;
    int cCount = cur.completedBookings;

    final index = list.indexWhere((b) {
      final id = (b['id'] ?? b['_id'] ?? '').toString();
      return id == event.bookingId;
    });

    if (index != -1) {
      final updated = Map<String, dynamic>.from(list[index] as Map);
      final oldStatus = (updated['status'] ?? '').toString().toLowerCase();
      updated['status'] = event.newStatus;
      list[index] = updated;

      if (oldStatus == 'pending' && event.newStatus.toLowerCase() != 'pending') {
        pCount = (pCount - 1).clamp(0, 9999);
      }
      if (event.newStatus.toLowerCase() == 'completed' && oldStatus != 'completed') {
        cCount = cCount + 1;
      }
    }

    emit(state.copyWith(
      dashboardData: cur.copyWith(
        recentBookings: list,
        pendingBookings: pCount,
        completedBookings: cCount,
      ),
    ));
  }
}

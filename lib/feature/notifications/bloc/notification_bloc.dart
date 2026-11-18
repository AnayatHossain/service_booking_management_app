import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/events/booking_event_bus.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import '../model/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  StreamSubscription? _statusSubscription;
  StreamSubscription? _ratedSubscription;

  NotificationBloc() : super(const NotificationState()) {
    on<NotificationFetchRequested>(_onFetchNotifications);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
    on<NotificationDeleteRequested>(_onDeleteNotification);

    _statusSubscription = BookingEventBus.stream.listen((event) {
      add(const NotificationFetchRequested());
    });

    _ratedSubscription = BookingEventBus.ratedStream.listen((event) {
      add(const NotificationFetchRequested());
    });

    add(const NotificationFetchRequested());
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _ratedSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchNotifications(
      NotificationFetchRequested event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading, errorMessage: null));

    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.notifications,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );

      final response = await api.call();

      if (response.isSuccess && response.data is Map && response.data['data'] is List) {
        final List<dynamic> list = response.data['data'];
        final notifications = list
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
        ));
      } else {
        emit(state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: response.errorMessage ?? 'Failed to load notifications.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: 'Network error: $e',
      ));
    }
  }

  Future<void> _onMarkAsRead(
      NotificationMarkAsReadRequested event, Emitter<NotificationState> emit) async {
    final updated = state.notifications.map((n) {
      if (n.id == event.id) return n.copyWith(isRead: true);
      return n;
    }).toList();

    emit(state.copyWith(notifications: updated));

    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.markNotificationRead(event.id),
        apiType: ApiType.patch,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      await api.call();
    } catch (_) {}
  }

  Future<void> _onMarkAllAsRead(
      NotificationMarkAllAsReadRequested event, Emitter<NotificationState> emit) async {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updated));

    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.markAllNotificationsRead,
        apiType: ApiType.patch,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      await api.call();
    } catch (_) {}
  }

  Future<void> _onDeleteNotification(
      NotificationDeleteRequested event, Emitter<NotificationState> emit) async {
    final original = List<NotificationModel>.from(state.notifications);
    final updated = state.notifications.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notifications: updated));

    try {
      final token = await Urls.bearerToken;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.deleteNotification(event.id),
        apiType: ApiType.delete,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final response = await api.call();
      if (!response.isSuccess) {
        emit(state.copyWith(
          notifications: original,
          errorMessage: response.errorMessage ?? 'Failed to delete notification.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        notifications: original,
        errorMessage: 'Network error deleting notification.',
      ));
    }
  }
}

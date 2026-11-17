import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/global_widegts/empty_screen_widget.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.calendar_month_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return AppColors.primaryColor;
      case 'promo':
        return Colors.deepOrange;
      case 'reminder':
        return Colors.teal;
      default:
        return AppColors.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final bloc = context.read<NotificationBloc>();

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                if (state.notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: () {
                      bloc.add(const NotificationMarkAllAsReadRequested());
                    },
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async {
                bloc.add(const NotificationFetchRequested());
              },
              child: state.status == NotificationStatus.loading && state.notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : state.notifications.isEmpty
                      ? const EmptyScreenWidget(
                          title: 'No Notifications',
                          subtitle: 'You are all caught up! Updates and booking reminders will appear here.',
                          icon: Icons.notifications_none_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          itemCount: state.notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = state.notifications[index];
                            final iconColor = _getTypeColor(item.type);

                            return InkWell(
                              onTap: () {
                                if (!item.isRead) {
                                  bloc.add(NotificationMarkAsReadRequested(item.id));
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: item.isRead
                                        ? AppColors.strokeColor.withOpacity(0.8)
                                        : AppColors.primaryColor.withOpacity(0.3),
                                    width: item.isRead ? 1 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: iconColor.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(_getTypeIcon(item.type), color: iconColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              if (!item.isRead) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.primaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.message,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}

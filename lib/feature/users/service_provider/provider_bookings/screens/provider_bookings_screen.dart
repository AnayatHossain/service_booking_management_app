import 'package:flutter/material.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _allBookings = [];

  final List<String> _tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    final token = await Urls.bearerToken;
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerBookings,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final res = await api.call();
      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        _allBookings = res.data['data'];
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    final token = await Urls.bearerToken;
    final api = FlutterApiCraft(
      baseUrl: Urls.baseUrl,
      path: Urls.providerUpdateBookingStatus(bookingId, newStatus),
      apiType: ApiType.patch,
      apiHeaders: {'Authorization': token},
      enableLoading: true,
      enableApiSuccessResponseGetSnackBar: true,
      enableApiErrorResponseGetSnackBar: true,
    );
    final res = await api.call();
    if (res.isSuccess) {
      _fetchBookings();
    }
  }

  List<dynamic> _getFilteredBookings(String tab) {
    if (tab == 'All') return _allBookings;
    return _allBookings.where((b) => (b['status'] ?? '').toString().toLowerCase() == tab.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Client Appointments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _fetchBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final list = _getFilteredBookings(tab);
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 50, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No $tab appointments found', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          const Text('Appointments with clients will be displayed here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = list[idx];
                      final status = (item['status'] ?? 'Pending').toString();
                      Color statusColor = const Color(0xFFE65100);
                      if (status.toLowerCase() == 'confirmed') statusColor = const Color(0xFF1976D2);
                      if (status.toLowerCase() == 'completed') statusColor = const Color(0xFF2E7D32);
                      if (status.toLowerCase() == 'cancelled') statusColor = AppColors.error;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.strokeColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['service_name'] ?? 'Service',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(item['user_name'] ?? 'Client', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                const Spacer(),
                                Text('\$${item['service_price'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryColor)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text('${item['date']} at ${item['time_slot']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            if (item['customer_notes'] != null && item['customer_notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Note: ${item['customer_notes']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                            if (status.toLowerCase() == 'pending') ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _updateStatus(item['id'] ?? item['_id'], 'Cancelled'),
                                    child: const Text('Decline'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _updateStatus(item['id'] ?? item['_id'], 'Confirmed'),
                                    child: const Text('Confirm Booking'),
                                  ),
                                ],
                              ),
                            ] else if (status.toLowerCase() == 'confirmed') ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _updateStatus(item['id'] ?? item['_id'], 'Completed'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Mark Service Completed'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}

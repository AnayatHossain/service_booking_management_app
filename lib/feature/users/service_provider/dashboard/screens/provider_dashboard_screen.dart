import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import 'package:service_booking_management_app/feature/auth/login/screen/login_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  String _providerName = 'Apex Pro Services';
  String _institutionName = 'Apex Care Solutions Ltd';
  bool _isLoading = true;
  int _totalServices = 0;
  int _totalBookings = 0;
  int _pendingBookings = 0;
  int _completedBookings = 0;
  List<dynamic> _recentBookings = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final name = await SharedPreferencesHelper.getUserName();
    final inst = await SharedPreferencesHelper.getInstitutionName();
    if (name != null) _providerName = name;
    if (inst != null) _institutionName = inst;

    final token = await Urls.bearerToken;
    final headers = {'Authorization': token};

    try {
      // Fetch services count
      final sApi = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerServices,
        apiType: ApiType.get,
        apiHeaders: headers,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final sRes = await sApi.call();
      if (sRes.isSuccess && sRes.data is Map && sRes.data['data'] is List) {
        _totalServices = (sRes.data['data'] as List).length;
      }

      // Fetch bookings
      final bApi = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerBookings,
        apiType: ApiType.get,
        apiHeaders: headers,
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final bRes = await bApi.call();
      if (bRes.isSuccess && bRes.data is Map && bRes.data['data'] is List) {
        final list = bRes.data['data'] as List;
        _totalBookings = list.length;
        _pendingBookings = list.where((b) => (b['status'] ?? '').toString().toLowerCase() == 'pending').length;
        _completedBookings = list.where((b) => (b['status'] ?? '').toString().toLowerCase() == 'completed').length;
        _recentBookings = list.take(5).toList();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
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
      _loadDashboardData();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out from Provider Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await SharedPreferencesHelper.clearUserSession();
              Get.offAll(() => const LoginScreen());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  _institutionName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            Text(
              'Service Provider Portal • $_providerName',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Business Overview',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active Provider',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _institutionName,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Managed by $_providerName',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // KPI Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('Total Services', '$_totalServices', Icons.inventory_2_rounded, const Color(0xFF1976D2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard('Total Bookings', '$_totalBookings', Icons.calendar_month_rounded, const Color(0xFF7B1FA2)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('Pending Action', '$_pendingBookings', Icons.hourglass_top_rounded, const Color(0xFFE65100)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard('Completed', '$_completedBookings', Icons.check_circle_rounded, const Color(0xFF2E7D32)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Client Appointments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Client Bookings',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    '$_totalBookings total',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primaryColor)))
              else if (_recentBookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.strokeColor),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text('No client bookings received yet', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('Client appointments will appear here.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final item = _recentBookings[idx];
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(item['user_name'] ?? 'Client', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(width: 14),
                              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${item['date']} • ${item['time_slot']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  onPressed: () => _updateBookingStatus(item['id'] ?? item['_id'], 'Cancelled'),
                                  child: const Text('Decline', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  ),
                                  onPressed: () => _updateBookingStatus(item['id'] ?? item['_id'], 'Confirmed'),
                                  child: const Text('Confirm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  ),
                                  onPressed: () => _updateBookingStatus(item['id'] ?? item['_id'], 'Completed'),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Mark Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

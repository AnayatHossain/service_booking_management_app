import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/services/shared_preferences_helper.dart';
import 'package:service_booking_management_app/feature/auth/login/screen/login_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/dashboard/screens/provider_dashboard_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/my_services/screens/provider_services_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/screens/provider_bookings_screen.dart';

class ProviderNavigationScreen extends StatefulWidget {
  const ProviderNavigationScreen({super.key});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProviderDashboardScreen(),
    ProviderServicesScreen(),
    ProviderBookingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'My Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Bookings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

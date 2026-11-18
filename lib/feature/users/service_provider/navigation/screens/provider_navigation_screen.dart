import 'package:flutter/material.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_bottom_navbar.dart';
import 'package:service_booking_management_app/feature/users/normal_user/profile/screens/profile_details_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/dashboard/screens/provider_dashboard_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/my_services/screens/provider_services_screen.dart';
import 'package:service_booking_management_app/feature/users/service_provider/provider_bookings/screens/provider_bookings_screen.dart';

class ProviderNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const ProviderNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProviderDashboardScreen(onProfileTap: () => _switchTab(3)),
      const ProviderServicesScreen(),
      const ProviderBookingsScreen(),
      const ProfileDetailsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              selectedIndex: _currentIndex,
              onItemTapped: _switchTab,
              items: const [
                NavItemData(
                  activeSvg: AppSvgIcons.dashboardFilled,
                  inactiveSvg: AppSvgIcons.dashboardOutline,
                  label: 'Dashboard',
                ),
                NavItemData(
                  activeSvg: AppSvgIcons.enterprise,
                  inactiveSvg: AppSvgIcons.enterprise,
                  label: 'My Services',
                ),
                NavItemData(
                  activeSvg: AppSvgIcons.bookingFilled,
                  inactiveSvg: AppSvgIcons.bookingOutline,
                  label: 'Bookings',
                ),
                NavItemData(
                  activeSvg: AppSvgIcons.userFilled,
                  inactiveSvg: AppSvgIcons.userOutline,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

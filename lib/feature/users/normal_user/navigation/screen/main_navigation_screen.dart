import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/global_widegts/custom_bottom_navbar.dart';
import '../bloc/navigation_cubit.dart';
import '../../home_screen/bloc/home_bloc.dart';
import '../../home_screen/bloc/home_event.dart';
import '../../home_screen/screens/home_screen.dart';
import '../../my_bookings/screens/my_bookings_screen.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_details_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit(initialIndex)),
        BlocProvider(create: (_) => HomeBloc()..add(const HomeDataRequested())),
      ],
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          final screens = const [
            HomeScreen(),
            MyBookingsScreen(),
            AiAssistantScreen(),
            ProfileDetailsScreen(),
          ];

          return Scaffold(
            backgroundColor: AppColors.bgColor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: currentIndex,
                    children: screens,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomBottomNavigationBar(
                    selectedIndex: currentIndex,
                    onItemTapped: (index) {
                      context.read<NavigationCubit>().changeTab(index);
                    },
                    items: const [
                      NavItemData(
                        activeSvg: AppSvgIcons.homeFilled,
                        inactiveSvg: AppSvgIcons.homeOutline,
                        label: 'Home',
                      ),
                      NavItemData(
                        activeSvg: AppSvgIcons.bookingFilled,
                        inactiveSvg: AppSvgIcons.bookingOutline,
                        label: 'Bookings',
                      ),
                      NavItemData(
                        activeSvg: AppSvgIcons.botFilled,
                        inactiveSvg: AppSvgIcons.botOutline,
                        label: 'AI Assistant',
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
        },
      ),
    );
  }
}

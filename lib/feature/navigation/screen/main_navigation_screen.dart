import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/const/app_colors.dart';
import '../bloc/navigation_cubit.dart';
import '../../home_screen/bloc/home_bloc.dart';
import '../../home_screen/bloc/home_event.dart';
import '../../home_screen/screens/home_screen.dart';
import '../../my_bookings/screens/my_bookings_screen.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => HomeBloc()..add(const HomeDataRequested())),
      ],
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          final screens = const [
            HomeScreen(),
            MyBookingsScreen(),
            AiAssistantScreen(),
            ProfileScreen(),
          ];

          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: screens,
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
                  currentIndex: currentIndex,
                  onTap: (index) {
                    context.read<NavigationCubit>().changeTab(index);
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
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month_outlined),
                      activeIcon: Icon(Icons.calendar_month_rounded),
                      label: 'Bookings',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.auto_awesome_outlined),
                      activeIcon: Icon(Icons.auto_awesome_rounded),
                      label: 'AI Assistant',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

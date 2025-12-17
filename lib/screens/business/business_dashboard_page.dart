import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/screens/business/appointments_page.dart';
import 'package:walkinsalonapp/screens/business/barber_management_page.dart';
import 'package:walkinsalonapp/screens/business/business_more_screen.dart';
import 'package:walkinsalonapp/widgets/dashboard/dashboard_body.dart';

// ✅ Tab State (Optional: Keep alive or auto-dispose)
class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void setIndex(int index) => state = index;
}

final dashboardTabProvider = NotifierProvider<DashboardTabNotifier, int>(DashboardTabNotifier.new);

class BusinessDashboardPage extends ConsumerWidget {
  const BusinessDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(dashboardTabProvider);

    final screens = const [
      DashboardBody(),
      AppointmentsPage(),
      BarberManagementPage(),
      BusinessMoreScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(dashboardTabProvider.notifier).setIndex(index);
        },
        backgroundColor: AppConfig.adaptiveSurface(context),
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Barbers',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

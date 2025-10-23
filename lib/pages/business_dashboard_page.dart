import 'package:flutter/material.dart';
import 'package:walkinsalonapp/widgets/dashboard/dashboard_body.dart';
import 'package:walkinsalonapp/widgets/dashboard/dashboard_appbar.dart';
import 'package:walkinsalonapp/widgets/dashboard/dashboard_drawer.dart';

class BusinessDashboardPage extends StatelessWidget {
  const BusinessDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerHighest.withOpacity(0.95),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DashboardAppBar(),
      ),
      drawer: const DashboardDrawer(),
      body: const DashboardBody(),
    );
  }
}

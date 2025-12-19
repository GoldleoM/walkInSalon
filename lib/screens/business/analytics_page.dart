import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/business_analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = BusinessAnalyticsService();
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _analyticsFuture = _service.getAnalytics(user.uid);
    } else {
      _analyticsFuture = Future.error("Not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text('Business Insights'),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final uniqueCustomers = data['uniqueCustomers'] as int;
          final totalRevenue = data['totalRevenue'] as double;
          final aov = data['aov'] as double;
          final topServices =
              data['topServices'] as List<MapEntry<String, int>>;
          final dailyEarnings = data['dailyEarnings'] as Map<String, double>;
          final peakHours = data['peakHours'] as Map<int, int>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: "Unique Clients",
                        value: "$uniqueCustomers",
                        icon: Icons.people_outline,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: "Avg. Order Value",
                        value: "₹${aov.toStringAsFixed(0)}",
                        icon: Icons.receipt_long,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  title: "Total Revenue",
                  value: "₹${totalRevenue.toStringAsFixed(0)}",
                  icon: Icons.attach_money,
                  color: Colors.amber, // Using amber separately
                  width: double.infinity,
                ),

                const SizedBox(height: 24),

                // Daily Earnings (List for simplicity, Chart ideal)
                Text(
                  "Recent Daily Earnings",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEarningsList(context, dailyEarnings),

                const SizedBox(height: 24),

                // Top Services
                Text(
                  "Top Services",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.glassPanel(context),
                  child: Column(
                    children: topServices.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${e.value} bookings",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Peak Hours
                Text(
                  "Peak Hours",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPeakHoursChart(context, peakHours),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsList(
    BuildContext context,
    Map<String, double> earnings,
  ) {
    final sortedKeys = earnings.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first
    return Container(
      decoration: AppDecorations.glassPanel(context),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedKeys.take(7).length, // Last 7 active days
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dateStr = sortedKeys[index];
          final amount = earnings[dateStr] ?? 0;
          DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
          return ListTile(
            title: Text(DateFormat('MMM dd, yyyy').format(date)),
            trailing: Text(
              "₹${amount.toStringAsFixed(0)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeakHoursChart(BuildContext context, Map<int, int> peakHours) {
    if (peakHours.isEmpty) return const Text("No data available");

    // Sort by hour
    final sorted = peakHours.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = peakHours.values.fold(
      0,
      (prev, curr) => curr > prev ? curr : prev,
    );

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassPanel(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: sorted.map((e) {
          final heightPct = maxVal > 0 ? e.value / maxVal : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${e.value}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 100 * heightPct + 10, // Min height 10
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(_formatHour(e.key), style: const TextStyle(fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

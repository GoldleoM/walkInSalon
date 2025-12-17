import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  List<ChartData> _chartData = [];
  bool _isLoading = true;
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyRevenue();
  }

  Future<void> _fetchWeeklyRevenue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('businessId', isEqualTo: uid)
          .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      final docs = snapshot.docs;
      double total = 0;

      // Group by Day
      // Note: We need to initialize the map with 0.0 for the last 7 days to show empty days.
      Map<int, double> revenueByDayIndex = {}; // 1=Mon, 7=Sun

      for (var doc in docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          // Only count completed!
          // But 'status' filter is not in query (requires composite index).
          // We filter locally.
          final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
          final date = (data['startAt'] as Timestamp).toDate();
          final dayIndex = date.weekday; // 1..7

          revenueByDayIndex[dayIndex] =
              (revenueByDayIndex[dayIndex] ?? 0) + price;
          total += price;
        }
      }

      // Prepare Chart Data (Ordered from 6 days ago to Today)
      List<ChartData> preparedData = [];
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayIndex = date.weekday;
        final revenue = revenueByDayIndex[dayIndex] ?? 0.0;
        preparedData.add(ChartData(weekdays[dayIndex - 1], revenue));
      }

      if (mounted) {
        setState(() {
          _chartData = preparedData;
          _totalRevenue = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching revenue: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: AppDecorations.glassPanel(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.glassPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Revenue",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConfig.adaptiveTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last 7 days",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.adaptiveTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "₹${_totalRevenue.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(
                  color: AppConfig.adaptiveTextColor(
                    context,
                  ).withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  dashArray: <double>[5, 5],
                ),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(
                  color: AppConfig.adaptiveTextColor(
                    context,
                  ).withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                labelFormat: '₹{value}',
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder:
                    (
                      dynamic data,
                      dynamic point,
                      dynamic series,
                      int pointIndex,
                      int seriesIndex,
                    ) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConfig.adaptiveSurface(
                            context,
                          ).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '₹${point.y.toInt()}',
                          style: TextStyle(
                            color: AppConfig.adaptiveTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<ChartData, String>(
                  dataSource: _chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderColor: AppColors.primary,
                  borderWidth: 4,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 8,
                    width: 8,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    borderColor: AppColors.primary,
                    color: AppConfig.adaptiveSurface(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

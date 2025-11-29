import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the last 7 days
    final List<ChartData> chartData = [
      ChartData('Mon', 150),
      ChartData('Tue', 280),
      ChartData('Wed', 220),
      ChartData('Thu', 450),
      ChartData('Fri', 380),
      ChartData('Sat', 520),
      ChartData('Sun', 480),
    ];

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
                    "Last 7 days performance",
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
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      "+12.5%",
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                labelFormat: '\${value}',
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
                          '\$${point.y.toInt()}',
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
                  dataSource: chartData,
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

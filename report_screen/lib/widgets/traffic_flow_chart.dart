import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/traffic_report_model.dart';

class TrafficFlowChart extends StatelessWidget {
  final List<TrafficReport> data; // filtered, sorted by time

  const TrafficFlowChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: SizedBox(height: 220, child: Center(child: Text('No data'))),
      );
    }

    // Ensure data sorted by time
    final sorted = [...data]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final spotsVolume = <FlSpot>[];
    final spotsSpeed = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spotsVolume.add(FlSpot(i.toDouble(), sorted[i].trafficVolume.toDouble()));
      spotsSpeed.add(FlSpot(i.toDouble(), sorted[i].averageSpeedMph));
    }

    final bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: (sorted.length / 4).clamp(1, 24).toDouble(),
        getTitlesWidget: (v, meta) {
          final idx = v.toInt();
          if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
          final label = DateFormat('HH:mm').format(sorted[idx].dateTime);
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          );
        },
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Traffic Flow',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                      ),
                    ),
                    bottomTitles: bottomTitles,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsVolume,
                      isCurved: true,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, applyCutOffY: true),
                    ),
                    LineChartBarData(
                      spots: spotsSpeed,
                      isCurved: true,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendDot(context, 'Volume'),
                const SizedBox(width: 12),
                _legendDot(context, 'Speed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(BuildContext context, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

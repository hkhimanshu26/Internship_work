import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/traffic_report_model.dart';

class VehicleDistributionChart extends StatelessWidget {
  final List<TrafficReport> data;

  const VehicleDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final counts = <VehicleClass, int>{
      VehicleClass.car: 0,
      VehicleClass.truck: 0,
      VehicleClass.bus: 0,
      VehicleClass.other: 0,
    };
    for (final r in data) {
      counts.update(
        r.vehicleClass,
        (v) => v + r.trafficVolume,
        ifAbsent: () => r.trafficVolume,
      );
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Card(
        child: SizedBox(height: 220, child: Center(child: Text('No data'))),
      );
    }

    final sections = counts.entries.map((e) {
      final pct = (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 48,
      );
    }).toList();

    String label(VehicleClass c) {
      switch (c) {
        case VehicleClass.car:
          return 'Cars';
        case VehicleClass.truck:
          return 'Trucks';
        case VehicleClass.bus:
          return 'Buses';
        case VehicleClass.other:
          return 'Other';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: sections,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: counts.entries.map((e) {
                    final pct = ((e.value / total) * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${label(e.key)} ($pct%)'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

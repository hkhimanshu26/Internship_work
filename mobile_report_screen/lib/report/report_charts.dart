import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/vehicle_data_model.dart';
import 'package:intl/intl.dart';

class ReportCharts extends StatelessWidget {
  final List<VehicleData> data;
  const ReportCharts({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final laneCounts = <int, int>{};
    final classCounts = <String, int>{};
    final timeBuckets = <DateTime, int>{};

    for (final v in data) {
      laneCounts[v.lane] = (laneCounts[v.lane] ?? 0) + 1;
      classCounts[v.vehicleClass] = (classCounts[v.vehicleClass] ?? 0) + 1;
      final t = DateTime(
        v.timestamp.year,
        v.timestamp.month,
        v.timestamp.day,
        v.timestamp.hour,
        (v.timestamp.minute ~/ 15) * 15,
      );
      timeBuckets[t] = (timeBuckets[t] ?? 0) + 1;
    }

    final laneEntries = laneCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final classEntries = classCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final timeEntries = timeBuckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Bar Chart - lanes
            _Section(
              title: 'Vehicles per Lane',
              child: SizedBox(
                height: 160,
                child: _LaneBarChart(entries: laneEntries),
              ),
            ),
            const SizedBox(height: 12),
            // Pie - classes
            _Section(
              title: 'Vehicle Class Distribution',
              child: SizedBox(
                height: 140,
                child: _ClassPieChart(entries: classEntries),
              ),
            ),
            const SizedBox(height: 12),
            // Line - time series
            _Section(
              title: 'Traffic Over Time (15m buckets)',
              child: SizedBox(
                height: 160,
                child: _TimeSeriesLine(entries: timeEntries),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _LaneBarChart extends StatelessWidget {
  final List<MapEntry<int, int>> entries;
  const _LaneBarChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('No data'));
    final max = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final bars = entries.asMap().entries.map((pair) {
      final idx = pair.key;
      final e = pair.value;
      return BarChartGroupData(
        x: idx,
        barRods: [BarChartRodData(toY: e.value.toDouble(), width: 18)],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (max * 1.2),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  'L${entries[idx].key}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}

class _ClassPieChart extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  const _ClassPieChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('No data'));
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    final sections = entries.asMap().entries.map((p) {
      final idx = p.key;
      final e = p.value;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
        radius: 40 + (idx == 0 ? 6 : 0),
      );
    }).toList();

    return PieChart(
      PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 28),
    );
  }
}

class _TimeSeriesLine extends StatelessWidget {
  final List<MapEntry<DateTime, int>> entries;
  const _TimeSeriesLine({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('No data'));
    entries
        .asMap()
        .entries
        .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
        .toList();
    // need X labels convert: use index as X and show time label below
    entries
        .asMap()
        .entries
        .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
        .toList();
    // simpler approach: use index for x
    entries
        .asMap()
        .entries
        .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
        .toList();
    // Build simple line using index as x
    entries
        .asMap()
        .entries
        .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
        .toList();

    // We'll use index-based X axis for labels
    entries
        .asMap()
        .entries
        .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final dt = entries[idx].key;
                return Text(
                  DateFormat('HH:mm').format(dt),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 36,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: entries
                .asMap()
                .entries
                .map((p) => FlSpot(p.key.toDouble(), p.value.value.toDouble()))
                .toList(),
            isCurved: true,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

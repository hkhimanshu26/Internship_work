import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/traffic_report_model.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_kpi_card.dart';
import '../widgets/traffic_data_table.dart';
import '../widgets/traffic_flow_chart.dart';
import '../widgets/volume_location_chart.dart';
import '../widgets/vehicle_distribution_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Filters
  DateTimeRange? _dateRange;
  String _reportType = 'Traffic Volume Analysis';
  String _location = 'All Locations';

  // Data (mocked for now)
  late List<TrafficReport> _allData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allData = _generateDummyData();
    // default range = last 1 day present in data
    final now = _allData
        .map((e) => e.dateTime)
        .fold<DateTime?>(
          null,
          (prev, d) => prev == null || d.isAfter(prev) ? d : prev,
        )!;
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 1)),
      end: now,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ========= DUMMY DATA (replace with your JSON later) =========
  List<TrafficReport> _generateDummyData() {
    final base = DateTime.now().subtract(const Duration(days: 2));
    final rng = Random(42);
    final locations = [
      'Main Street',
      'Highway 101',
      'Downtown',
      'West Ave',
      'East Blvd',
    ];
    final statusOptions = ['Normal', 'Warning', 'Critical'];
    final classes = VehicleClass.values;

    final List<TrafficReport> list = [];
    for (int h = 0; h < 48; h++) {
      for (final loc in locations) {
        final dt = base.add(Duration(hours: h));
        final volume = 200 + rng.nextInt(1800);
        final speed = 25 + rng.nextDouble() * 45;
        final violations = rng.nextInt(35);
        final status = statusOptions[rng.nextInt(statusOptions.length)];
        final vc = classes[rng.nextInt(classes.length)];
        list.add(
          TrafficReport(
            dateTime: dt,
            location: loc,
            trafficVolume: volume,
            averageSpeedMph: double.parse(speed.toStringAsFixed(1)),
            violations: violations,
            status: status,
            vehicleClass: vc,
          ),
        );
      }
    }
    return list;
  }

  // ========= FILTER & SUMMARY =========
  List<TrafficReport> get _filtered {
    final r = _dateRange;
    return _allData.where((e) {
      final inRange =
          r == null ||
          (!e.dateTime.isBefore(r.start) && !e.dateTime.isAfter(r.end));
      final locOk = _location == 'All Locations' || e.location == _location;
      // _reportType can be used to alter which charts/metrics we show; for now it doesn't filter rows.
      return inRange && locOk;
    }).toList();
  }

  ReportSummary get _summary {
    final rows = _filtered;
    if (rows.isEmpty) {
      return const ReportSummary(
        totalVehicles: 0,
        averageSpeedMph: 0,
        overloadedVehicles: 0,
        peakHour: null,
      );
    }

    int totalVehicles = 0;
    double sumSpeedWeighted = 0;
    int overloaded = 0;
    final byHour = <int, int>{};

    for (final r in rows) {
      totalVehicles += r.trafficVolume;
      sumSpeedWeighted += r.averageSpeedMph * r.trafficVolume;
      overloaded += r.violations;
      final h = TimeOfDay.fromDateTime(r.dateTime).hour;
      byHour.update(
        h,
        (v) => v + r.trafficVolume,
        ifAbsent: () => r.trafficVolume,
      );
    }

    final peakHour = byHour.entries.isEmpty
        ? null
        : TimeOfDay(
            hour: byHour.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key,
            minute: 0,
          );

    final avgSpeed = totalVehicles == 0 ? 0 : sumSpeedWeighted / totalVehicles;

    return ReportSummary(
      totalVehicles: totalVehicles,
      averageSpeedMph: double.parse(avgSpeed.toStringAsFixed(1)),
      overloadedVehicles: overloaded,
      peakHour: peakHour,
    );
  }

  void _applyFilters(DateTimeRange? range, String type, String location) {
    setState(() {
      _dateRange = range;
      _reportType = type;
      _location = location;
    });
  }

  // ========= EXPORT (CSV to clipboard for now) =========
  void _exportCsv() {
    final rows = _filtered;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer(
      'DateTime,Location,TrafficVolume,AvgSpeedMph,Violations,Status\n',
    );
    for (final r in rows) {
      buf.writeln(
        '${fmt.format(r.dateTime)},${r.location},${r.trafficVolume},'
        '${r.averageSpeedMph.toStringAsFixed(1)},${r.violations},${r.status}',
      );
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV copied to clipboard. Paste into a .csv file.'),
      ),
    );
  }

  // ========= UI =========
  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final nowStr = DateFormat('MMM d, yyyy HH:mm').format(DateTime.now());
    final locations = [
      'All Locations',
      ..._allData.map((e) => e.location).toSet(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          Tooltip(
            message: 'PDF (todo)',
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ),
          Tooltip(
            message: 'Excel (todo)',
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.grid_on_outlined),
            ),
          ),
          Tooltip(
            message: 'CSV',
            child: IconButton(
              onPressed: _exportCsv,
              icon: const Icon(Icons.table_view_outlined),
            ),
          ),
          Tooltip(
            message: 'Share (todo)',
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Last updated
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Last updated: $nowStr',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),

            // Filters
            ReportFilters(
              initialRange: _dateRange,
              initialReportType: _reportType,
              initialLocation: _location,
              reportTypes: const [
                'Traffic Volume Analysis',
                'Speed Analysis',
                'Violations Overview',
              ],
              locations: locations,
              onApply: _applyFilters,
            ),
            const SizedBox(height: 16),

            // KPI cards
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth > 1000;
                final items = [
                  ReportKpiCard(
                    title: 'Total Vehicles',
                    value: NumberFormat.decimalPattern().format(
                      summary.totalVehicles,
                    ),
                    deltaLabel: '↑ sample vs last week',
                    leading: Icons.route_outlined,
                  ),
                  ReportKpiCard(
                    title: 'Average Speed',
                    value: '${summary.averageSpeedMph.toStringAsFixed(1)} mph',
                    deltaLabel: '↓ sample vs last week',
                    leading: Icons.speed_outlined,
                  ),
                  ReportKpiCard(
                    title: 'Overloaded Vehicles',
                    value: NumberFormat.decimalPattern().format(
                      summary.overloadedVehicles,
                    ),
                    deltaLabel: '↑ sample vs last week',
                    leading: Icons.warning_amber_outlined,
                  ),
                  ReportKpiCard(
                    title: 'Peak Traffic Hour',
                    value: summary.peakHour == null
                        ? '-'
                        : summary.peakHour!.format(context),
                    deltaLabel: 'Consistent with last week',
                    leading: Icons.access_time,
                  ),
                ];
                if (wide) {
                  return Row(
                    children:
                        items
                            .map(
                              (w) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: w,
                                ),
                              ),
                            )
                            .toList()
                          ..last = Expanded(
                            child: items.last,
                          ), // drop trailing padding on last
                  );
                } else {
                  return Column(
                    children: items
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: w,
                          ),
                        )
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            // Tabs: Table | Graphs
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Table View'),
                  Tab(text: 'Graphs'),
                ],
              ),
            ),
            SizedBox(
              height: 12,
              child:
                  Container(), // small spacer so TabBar shadow doesn't collide
            ),
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  // Table
                  return TrafficDataTable(rows: _filtered);
                } else {
                  // Graphs — place three cards in a responsive grid
                  return LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth > 1100;
                      final mid = c.maxWidth > 750;
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TrafficFlowChart(data: _filtered),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  VolumeLocationChart(data: _filtered),
                                  const SizedBox(height: 16),
                                  VehicleDistributionChart(data: _filtered),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (mid) {
                        return Column(
                          children: [
                            TrafficFlowChart(data: _filtered),
                            Row(
                              children: [
                                Expanded(
                                  child: VolumeLocationChart(data: _filtered),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: VehicleDistributionChart(
                                    data: _filtered,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            TrafficFlowChart(data: _filtered),
                            VolumeLocationChart(data: _filtered),
                            VehicleDistributionChart(data: _filtered),
                          ],
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

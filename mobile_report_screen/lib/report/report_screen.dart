import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/vehicle_data_model.dart';
import 'report_filters.dart';
import 'report_kpi_cards.dart';
import 'report_charts.dart';
import 'report_table.dart';
import 'report_export.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  List<VehicleData> _all = [];
  List<VehicleData> _filtered = [];
  bool _loading = true;

  // filters
  int? _laneFilter;
  Set<String> _classFilter = {};
  DateTimeRange? _range;

  // UI tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final raw = await rootBundle.loadString('assets/vehicle_data.json');
    _all = VehicleData.listFromJson(raw);
    // default range = full data window
    if (_all.isNotEmpty) {
      final sorted = [..._all]
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _range = DateTimeRange(
        start: sorted.first.timestamp,
        end: sorted.last.timestamp,
      );
    }
    _applyFilters();
    setState(() => _loading = false);
  }

  void _applyFilters() {
    setState(() {
      _filtered = _all.where((v) {
        if (_laneFilter != null && v.lane != _laneFilter) return false;
        if (_classFilter.isNotEmpty && !_classFilter.contains(v.vehicleClass)) {
          return false;
        }
        if (_range != null) {
          if (v.timestamp.isBefore(_range!.start) ||
              v.timestamp.isAfter(_range!.end)) {
            return false;
          }
        }
        return true;
      }).toList();
      _filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  void _onFilterChanged({
    int? lane,
    Set<String>? classes,
    DateTimeRange? range,
  }) {
    _laneFilter = lane;
    if (classes != null) _classFilter = classes;
    _range = range;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Report'),
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () => ExportService.exportPdf(context, _filtered, _range),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
          ),
          IconButton(
            onPressed: _loading
                ? null
                : () => ExportService.exportExcel(context, _filtered),
            icon: const Icon(Icons.grid_on),
            tooltip: 'Export Excel',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  ReportFilters(
                    all: _all,
                    currentLane: _laneFilter,
                    currentClasses: _classFilter,
                    currentRange: _range,
                    onChanged: _onFilterChanged,
                  ),
                  const SizedBox(height: 12),
                  ReportKpiCards(data: _filtered),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.black54,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: const [
                            Tab(text: 'Graph View'),
                            Tab(text: 'Table View'),
                          ],
                        ),
                        SizedBox(
                          height: 420,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ReportCharts(data: _filtered),
                              ReportTable(data: _filtered),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _filtered.isEmpty
                              ? null
                              : () => ExportService.shareReport(
                                  context,
                                  _filtered,
                                ),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

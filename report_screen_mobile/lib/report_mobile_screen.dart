import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Consistent palette (mirrors your dark web version)
class ReportPalette {
  final Color bg,
      card,
      elev,
      primary,
      accent,
      warning,
      danger,
      textPrimary,
      textSecondary;
  const ReportPalette({
    required this.bg,
    required this.card,
    required this.elev,
    required this.primary,
    required this.accent,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
  });
}

/// Simple model for list tiles
class TrafficReportRow {
  final String location;
  final DateTime timestamp;
  final int trafficVolume; // vehicles
  final double avgSpeed; // mph
  final int violations; // count
  final TrafficStatus status;

  TrafficReportRow({
    required this.location,
    required this.timestamp,
    required this.trafficVolume,
    required this.avgSpeed,
    required this.violations,
    required this.status,
  });
}

enum TrafficStatus { normal, warning, critical }

class ReportMobileScreen extends StatefulWidget {
  final ReportPalette palette;
  const ReportMobileScreen({super.key, required this.palette});

  @override
  State<ReportMobileScreen> createState() => _ReportMobileScreenState();
}

class _ReportMobileScreenState extends State<ReportMobileScreen> {
  // Filters
  DateTimeRange? _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );
  String _reportType = 'Traffic Volume Analysis';
  String _location = 'All Locations';

  // Data
  late List<TrafficReportRow> _rows;
  late List<TrafficReportRow> _filtered;

  // Metrics (mocked, recomputed from filtered)
  int get totalVehicles => _filtered.fold(0, (s, r) => s + r.trafficVolume);
  double get avgSpeed => _filtered.isEmpty
      ? 0
      : _filtered.map((e) => e.avgSpeed).reduce((a, b) => a + b) /
          _filtered.length;
  int get overloaded => _filtered.fold(0,
      (s, r) => s + (r.violations)); // treat violations as overloaded for demo
  TimeOfDay get peakTime {
    if (_filtered.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final map = <int, int>{}; // hour -> total
    for (final r in _filtered) {
      final h = r.timestamp.hour;
      map[h] = (map[h] ?? 0) + r.trafficVolume;
    }
    final bestHour =
        map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return TimeOfDay(hour: bestHour, minute: 0);
  }

  @override
  void initState() {
    super.initState();
    _rows = _mockData();
    _filtered = List.of(_rows);
  }

  // --- UI BUILD ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final dateLabel = _range == null
        ? 'Select dates'
        : '${DateFormat('MMM dd, yyyy').format(_range!.start)} - ${DateFormat('MMM dd, yyyy').format(_range!.end)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _share,
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              // Last updated (top caption)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Last updated: ${DateFormat('MMM d, yyyy • HH:mm').format(DateTime.now())}',
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ),

              // ---------------- Filters Card ----------------
              _SectionCard(
                palette: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                        title: 'Filters',
                        trailing: Icon(Icons.tune, color: p.textSecondary)),
                    const SizedBox(height: 8),
                    _LabeledField(
                      label: 'Date Range',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDateRange,
                        child: InputDecorator(
                          decoration: const InputDecoration(),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(dateLabel)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LabeledField(
                      label: 'Report Type',
                      child: DropdownButtonFormField<String>(
                        value: _reportType,
                        items: const [
                          DropdownMenuItem(
                              value: 'Traffic Volume Analysis',
                              child: Text('Traffic Volume Analysis')),
                          DropdownMenuItem(
                              value: 'Speed & Violations',
                              child: Text('Speed & Violations')),
                          DropdownMenuItem(
                              value: 'Axle/Weight Summary',
                              child: Text('Axle/Weight Summary')),
                        ],
                        onChanged: (v) =>
                            setState(() => _reportType = v ?? _reportType),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LabeledField(
                      label: 'Location',
                      child: DropdownButtonFormField<String>(
                        value: _location,
                        items: const [
                          DropdownMenuItem(
                              value: 'All Locations',
                              child: Text('All Locations')),
                          DropdownMenuItem(
                              value: 'Main Street', child: Text('Main Street')),
                          DropdownMenuItem(
                              value: 'Highway 101', child: Text('Highway 101')),
                          DropdownMenuItem(
                              value: 'Downtown', child: Text('Downtown')),
                        ],
                        onChanged: (v) =>
                            setState(() => _location = v ?? _location),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ---------------- KPI Tiles ----------------
              _KpiGrid(
                palette: p,
                items: [
                  KpiItem(
                    title: 'Total Vehicles',
                    value: NumberFormat.compact().format(totalVehicles),
                    sub: '+2.8% vs last week',
                    chipColor: p.accent,
                    icon: Icons.directions_car,
                  ),
                  KpiItem(
                    title: 'Avg Speed',
                    value: '${avgSpeed.toStringAsFixed(1)} mph',
                    sub: '↓ 1.2% vs last week',
                    chipColor: p.primary,
                    icon: Icons.speed,
                  ),
                  KpiItem(
                    title: 'Overloaded',
                    value: NumberFormat.compact().format(overloaded),
                    sub: '↑ 4.3% vs last week',
                    chipColor: p.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                  KpiItem(
                    title: 'Peak Traffic',
                    value: DateFormat('h:mm a').format(
                      DateTime(0, 1, 1, peakTime.hour, peakTime.minute),
                    ),
                    sub: 'Detected',
                    chipColor: p.danger,
                    icon: Icons.access_time_filled,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------------- Traffic Data List ----------------
              _SectionCard(
                palette: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Traffic Data',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _search,
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                          ),
                          IconButton(
                            onPressed: _sort,
                            icon: const Icon(Icons.sort),
                            tooltip: 'Sort',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._filtered
                        .map<Widget>((r) => _TrafficTile(row: r, palette: p))
                        .followedBy(const [SizedBox(height: 6)]),
                    // keep list fixed size for perf
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- Traffic Flow (Line) ----------------
              _SectionCard(
                palette: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                        title: 'Traffic Flow', subtitle: 'Volume • Speed'),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 1.25,
                      child: LineChart(_flowData(context, p)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- Volume by Location (Bar) ----------------
              _SectionCard(
                palette: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Volume by Location'),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: BarChart(_volumeByLocationData(context, p)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- Vehicle Distribution (Pie) ----------------
              _SectionCard(
                palette: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Vehicle Distribution'),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        height: 220,
                        child: PieChart(_vehicleDistributionData(context, p)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        NumberFormat('#,###').format(totalVehicles),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('Total',
                          style:
                              TextStyle(color: p.textSecondary, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: const [
                        _LegendDot(label: 'Cars'),
                        _LegendDot(label: 'Trucks'),
                        _LegendDot(label: 'Buses'),
                        _LegendDot(label: 'Other'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- Pagination (mobile friendly) ----------------
              _PaginationRow(palette: p),
            ],
          ),
        ),
      ),
    );
  }

  // --- Actions -----------------------------------------------------------------

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Share tapped (wire up platform share here)')),
    );
  }

  void _search() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search tapped (open bottom sheet search)')),
    );
  }

  void _sort() {
    setState(() {
      _filtered.sort((a, b) => b.trafficVolume.compareTo(a.trafficVolume));
    });
  }

  void _applyFilters() {
    setState(() {
      _filtered = _rows.where((r) {
        final matchesLocation =
            _location == 'All Locations' || r.location == _location;
        final matchesDate = _range == null ||
            (r.timestamp.isAfter(
                    _range!.start.subtract(const Duration(seconds: 1))) &&
                r.timestamp
                    .isBefore(_range!.end.add(const Duration(seconds: 1))));
        return matchesLocation && matchesDate;
      }).toList();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
      builder: (context, child) {
        // Keep dark styling tight to your theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: widget.palette.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  // --- Charts ------------------------------------------------------------------

  LineChartData _flowData(BuildContext context, ReportPalette p) {
    // Mock timeseries: 12 points
    final spotsA = List.generate(
        12, (i) => FlSpot(i.toDouble(), (i * 8 % 40 + 20).toDouble()));
    final spotsB = List.generate(
        12, (i) => FlSpot(i.toDouble(), (i * 6 % 30 + 30).toDouble()));

    return LineChartData(
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: const Color(0x223B4B5F), strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                    style: TextStyle(color: p.textSecondary, fontSize: 10)))),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: const Color(0x223B4B5F))),
      lineBarsData: [
        LineChartBarData(
            spots: spotsA,
            isCurved: true,
            barWidth: 2,
            dotData: const FlDotData(show: false)),
        LineChartBarData(
            spots: spotsB,
            isCurved: true,
            barWidth: 2,
            dotData: const FlDotData(show: false)),
      ],
    );
  }

  BarChartData _volumeByLocationData(BuildContext context, ReportPalette p) {
    final cats = <String, double>{
      'Main': 48,
      'Hwy 101': 62,
      'Downtown': 35,
      'Bypass': 28
    };
    final groups = <BarChartGroupData>[];
    var x = 0;
    for (final e in cats.entries) {
      groups.add(
        BarChartGroupData(
          x: x++,
          barRods: [
            BarChartRodData(
                toY: e.value, width: 16, borderRadius: BorderRadius.circular(4))
          ],
          showingTooltipIndicators: const [0],
        ),
      );
    }

    return BarChartData(
      barGroups: groups,
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: const Color(0x223B4B5F), strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(cats.keys.elementAt(value.toInt()),
                  style: TextStyle(color: p.textSecondary, fontSize: 11)),
            ),
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: const Color(0x223B4B5F))),
    );
  }

  PieChartData _vehicleDistributionData(BuildContext context, ReportPalette p) {
    final vals = {'Cars': 70.0, 'Trucks': 10.0, 'Buses': 9.0, 'Other': 11.0};
    final sections = <PieChartSectionData>[];
    var idx = 0;
    for (final e in vals.entries) {
      sections.add(
        PieChartSectionData(
          value: e.value,
          title: '${e.value.toStringAsFixed(0)}%',
          titleStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          radius: 58 + (idx == 0 ? 4.0 : 0.0),
        ),
      );
      idx++;
    }
    return PieChartData(
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 34,
    );
  }

  // --- Mock data ---------------------------------------------------------------

  List<TrafficReportRow> _mockData() {
    final now = DateTime.now();
    return [
      TrafficReportRow(
        location: 'Main Street',
        timestamp: now.subtract(const Duration(hours: 2)),
        trafficVolume: 487,
        avgSpeed: 42.3,
        violations: 5,
        status: TrafficStatus.normal,
      ),
      TrafficReportRow(
        location: 'Highway 101',
        timestamp: now.subtract(const Duration(hours: 6)),
        trafficVolume: 1245,
        avgSpeed: 58.7,
        violations: 12,
        status: TrafficStatus.warning,
      ),
      TrafficReportRow(
        location: 'Downtown',
        timestamp: now.subtract(const Duration(hours: 11)),
        trafficVolume: 856,
        avgSpeed: 32.1,
        violations: 3,
        status: TrafficStatus.normal,
      ),
      TrafficReportRow(
        location: 'Highway 101',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        trafficVolume: 1375,
        avgSpeed: 47.2,
        violations: 28,
        status: TrafficStatus.critical,
      ),
    ];
  }
}

// ==============================================================================
// Widgets (kept in same file for easy drop-in; feel free to split later)
// ==============================================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  final ReportPalette palette;
  const _SectionCard({required this.child, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x223B4B5F)),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: ts.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!,
                      style: ts.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .65))),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: .7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: secondary)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class KpiItem {
  final String title, value, sub;
  final IconData icon;
  final Color chipColor;
  KpiItem(
      {required this.title,
      required this.value,
      required this.sub,
      required this.icon,
      required this.chipColor});
}

class _KpiGrid extends StatelessWidget {
  final ReportPalette palette;
  final List<KpiItem> items;
  const _KpiGrid({required this.palette, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final it = items[i];
        return _KpiTile(item: it, palette: palette);
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  final KpiItem item;
  final ReportPalette palette;
  const _KpiTile({required this.item, required this.palette});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      palette: palette,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: palette.elev, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(10),
            child: Icon(item.icon, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style:
                        TextStyle(fontSize: 12, color: palette.textSecondary)),
                const SizedBox(height: 4),
                Text(item.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.chipColor.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.sub,
                          style:
                              TextStyle(fontSize: 10, color: item.chipColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficTile extends StatelessWidget {
  final TrafficReportRow row;
  final ReportPalette palette;
  const _TrafficTile({required this.row, required this.palette});

  Color _badgeColor() {
    switch (row.status) {
      case TrafficStatus.normal:
        return palette.accent;
      case TrafficStatus.warning:
        return palette.warning;
      case TrafficStatus.critical:
        return palette.danger;
    }
  }

  String _badgeText() {
    switch (row.status) {
      case TrafficStatus.normal:
        return 'Normal';
      case TrafficStatus.warning:
        return 'Warning';
      case TrafficStatus.critical:
        return 'Critical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = palette.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x223B4B5F)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: palette.elev, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(width: 12),
            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(row.location,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    _StatusPill(text: _badgeText(), color: _badgeColor()),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM d, yyyy • HH:mm').format(row.timestamp),
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _StatChip(
                          icon: Icons.directions_car,
                          label: 'Traffic Vol',
                          value: '${row.trafficVolume}'),
                      _StatChip(
                          icon: Icons.speed,
                          label: 'Avg Speed',
                          value: '${row.avgSpeed.toStringAsFixed(1)} mph'),
                      _StatChip(
                          icon: Icons.gpp_maybe,
                          label: 'Violations',
                          value: '${row.violations}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16, color: theme.colorScheme.onSurface.withValues(alpha: .8)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: .75))),
          const SizedBox(width: 6),
          Text('•',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: .35))),
          const SizedBox(width: 6),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  const _LegendDot({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface.withValues(alpha: .75);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: c, fontSize: 12)),
      ],
    );
  }
}

class _PaginationRow extends StatelessWidget {
  final ReportPalette palette;
  const _PaginationRow({required this.palette});

  @override
  Widget build(BuildContext context) {
    final muted = palette.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
        ...List.generate(3, (i) {
          final isActive = i == 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? palette.primary.withValues(alpha: .18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          isActive ? palette.primary : const Color(0x223B4B5F)),
                ),
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: isActive ? Colors.white : muted,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          );
        }),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

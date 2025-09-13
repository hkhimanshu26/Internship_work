import 'package:flutter/material.dart';

class ReportFilters extends StatefulWidget {
  final DateTimeRange? initialRange;
  final String initialReportType;
  final String initialLocation;
  final List<String> reportTypes;
  final List<String> locations;
  final void Function(DateTimeRange? range, String reportType, String location)
  onApply;

  const ReportFilters({
    super.key,
    required this.initialRange,
    required this.initialReportType,
    required this.initialLocation,
    required this.reportTypes,
    required this.locations,
    required this.onApply,
  });

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  DateTimeRange? _range;
  late String _reportType;
  late String _location;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
    _reportType = widget.initialReportType;
    _location = widget.initialLocation;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range ?? DateTimeRange(start: lastWeek, end: now),
      builder: (context, child) {
        // Keeps it nice in dark mode, too.
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final spacing = const SizedBox(width: 12, height: 12);

    Widget dateField = Expanded(
      flex: isWide ? 2 : 0,
      child: InkWell(
        onTap: _pickRange,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date Range',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: Text(
            _range == null
                ? 'Select range'
                : '${_range!.start.toString().split(" ").first} - ${_range!.end.toString().split(" ").first}',
          ),
        ),
      ),
    );

    Widget typeField = Expanded(
      child: DropdownButtonFormField<String>(
        value: _reportType,
        isExpanded: true,
        items: widget.reportTypes
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => _reportType = v ?? _reportType),
        decoration: const InputDecoration(
          labelText: 'Report Type',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );

    Widget locationField = Expanded(
      child: DropdownButtonFormField<String>(
        value: _location,
        isExpanded: true,
        items: widget.locations
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => _location = v ?? _location),
        decoration: const InputDecoration(
          labelText: 'Location',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );

    Widget applyBtn = SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: () => widget.onApply(_range, _reportType, _location),
        icon: const Icon(Icons.check),
        label: const Text('Apply Filters'),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  dateField,
                  spacing,
                  typeField,
                  spacing,
                  locationField,
                  spacing,
                  applyBtn,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dateField,
                  spacing,
                  typeField,
                  spacing,
                  locationField,
                  spacing,
                  applyBtn,
                ],
              ),
      ),
    );
  }
}

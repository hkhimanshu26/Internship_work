import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_data_model.dart';

class ReportFilters extends StatefulWidget {
  final List<VehicleData> all;
  final int? currentLane;
  final Set<String> currentClasses;
  final DateTimeRange? currentRange;
  final void Function({int? lane, Set<String>? classes, DateTimeRange? range})
  onChanged;

  const ReportFilters({
    super.key,
    required this.all,
    required this.currentLane,
    required this.currentClasses,
    required this.currentRange,
    required this.onChanged,
  });

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  int? _lane;
  Set<String> _classes = {};
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _lane = widget.currentLane;
    _classes = Set.from(widget.currentClasses);
    _range = widget.currentRange;
  }

  List<int> get lanes => widget.all.map((e) => e.lane).toSet().toList()..sort();
  List<String> get classes =>
      widget.all.map((e) => e.vehicleClass).toSet().toList()..sort();

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial =
        _range ??
        DateTimeRange(start: now.subtract(const Duration(hours: 1)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
    if (picked != null) {
      setState(() => _range = picked);
      widget.onChanged(lane: _lane, classes: _classes, range: _range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, HH:mm');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildLaneDropdown()),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _range == null
                      ? 'Select range'
                      : '${fmt.format(_range!.start)} - ${fmt.format(_range!.end)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: classes
                .map(
                  (c) => FilterChip(
                    label: Text(c),
                    selected: _classes.contains(c),
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          _classes.add(c);
                        } else {
                          _classes.remove(c);
                        }
                      });
                      widget.onChanged(
                        lane: _lane,
                        classes: _classes,
                        range: _range,
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLaneDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButton<int?>(
        value: _lane,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All Lanes')),
          ...lanes.map(
            (l) => DropdownMenuItem<int?>(value: l, child: Text('Lane $l')),
          ),
        ],

        onChanged: (v) {
          setState(() => _lane = v);
          widget.onChanged(lane: _lane, classes: _classes, range: _range);
        },
      ),
    );
  }
}

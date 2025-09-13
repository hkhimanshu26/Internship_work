import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_data_model.dart';

class ReportTable extends StatefulWidget {
  final List<VehicleData> data;
  const ReportTable({super.key, required this.data});

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    if (widget.data.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(20), child: Text('No records')),
      );
    }

    final totalPages = (widget.data.length / _rowsPerPage).ceil();
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, widget.data.length);
    final visibleRows = widget.data.sublist(start, end);

    return Column(
      children: [
        // Table with scroll
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Vehicle ID')),
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Lane')),
                  DataColumn(label: Text('Speed')),
                  DataColumn(label: Text('Weight (kg)')),
                  DataColumn(label: Text('Time')),
                ],
                rows: visibleRows.map((v) {
                  return DataRow(
                    cells: [
                      DataCell(Text(v.vehicleId)),
                      DataCell(Text(v.vehicleClass)),
                      DataCell(Text('${v.lane}')),
                      DataCell(Text(v.speedKmph.toStringAsFixed(1))),
                      DataCell(Text(v.grossWeightKg.toStringAsFixed(0))),
                      DataCell(Text(fmt.format(v.timestamp))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Pagination controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text('Page ${_currentPage + 1} of $totalPages'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: end < widget.data.length
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

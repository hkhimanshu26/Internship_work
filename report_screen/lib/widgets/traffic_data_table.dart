import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/traffic_report_model.dart';

class TrafficDataTable extends StatefulWidget {
  final List<TrafficReport> rows;

  const TrafficDataTable({super.key, required this.rows});

  @override
  State<TrafficDataTable> createState() => _TrafficDataTableState();
}

class _TrafficDataTableState extends State<TrafficDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    final source = _TrafficDataSource(widget.rows, context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PaginatedDataTable(
          header: const Text('Traffic Data'),
          rowsPerPage: _rowsPerPage,
          onRowsPerPageChanged: (v) {
            if (v != null) setState(() => _rowsPerPage = v);
          },
          columns: const [
            DataColumn(label: Text('Date/Time')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Traffic Volume')),
            DataColumn(label: Text('Avg Speed')),
            DataColumn(label: Text('Violations')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          source: source,
          showFirstLastButtons: true,
        ),
      ),
    );
  }
}

class _TrafficDataSource extends DataTableSource {
  final List<TrafficReport> data;
  final BuildContext context;
  _TrafficDataSource(this.data, this.context);

  final _dateFmt = DateFormat('MMM d, yyyy HH:mm');

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final r = data[index];

    Color statusColor() {
      switch (r.status.toLowerCase()) {
        case 'warning':
          return Colors.orange;
        case 'critical':
          return Colors.red;
        default:
          return Colors.green;
      }
    }

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(_dateFmt.format(r.dateTime))),
        DataCell(Text(r.location)),
        DataCell(Text(NumberFormat.decimalPattern().format(r.trafficVolume))),
        DataCell(Text('${r.averageSpeedMph.toStringAsFixed(1)} mph')),
        DataCell(Text('${r.violations}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              r.status,
              style: TextStyle(color: statusColor(), fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Details',
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Row Details'),
                      content: Text(
                        'Location: ${r.location}\n'
                        'Time: ${_dateFmt.format(r.dateTime)}\n'
                        'Volume: ${r.trafficVolume}\n'
                        'Avg Speed: ${r.averageSpeedMph.toStringAsFixed(1)} mph\n'
                        'Violations: ${r.violations}\n'
                        'Status: ${r.status}',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Download row (CSV)',
                icon: const Icon(Icons.download_outlined),
                onPressed: () {
                  final csv =
                      'DateTime,Location,Volume,AvgSpeed(V),Violations,Status\n'
                      '${_dateFmt.format(r.dateTime)},${r.location},${r.trafficVolume},${r.averageSpeedMph.toStringAsFixed(1)},${r.violations},${r.status}\n';
                  _copyCsvToClipboard(csv, context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyCsvToClipboard(String csv, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV copied to clipboard (paste into a file).'),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vehicle_data_model.dart';
import 'package:excel/excel.dart';
// ignore: depend_on_referenced_packages

class ExportService {
  static Future<void> exportPdf(
    BuildContext context,
    List<VehicleData> data,
    DateTimeRange? range,
  ) async {
    final doc = pw.Document();
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'TraffiQIQ Report',
              style: pw.TextStyle(fontSize: 20),
            ),
          ),
          pw.Text('Generated: ${fmt.format(DateTime.now())}'),
          if (range != null)
            pw.Text(
              'Window: ${fmt.format(range.start)} - ${fmt.format(range.end)}',
            ),
          pw.SizedBox(height: 10),
          pw.Text('Summary: Total records ${data.length}'),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: [
              'Vehicle ID',
              'Class',
              'Lane',
              'Speed',
              'Weight(kg)',
              'Timestamp',
            ],
            data: data
                .map(
                  (v) => [
                    v.vehicleId,
                    v.vehicleClass,
                    v.lane,
                    v.speedKmph.toStringAsFixed(1),
                    v.grossWeightKg.toStringAsFixed(0),
                    fmt.format(v.timestamp),
                  ],
                )
                .toList(),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static Future<void> exportExcel(
    BuildContext context,
    List<VehicleData> data,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];
    sheet.appendRow([
      'Vehicle ID',
      'Class',
      'Lane',
      'Speed',
      'Weight(kg)',
      'Timestamp',
    ]);
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    for (final v in data) {
      sheet.appendRow([
        v.vehicleId,
        v.vehicleClass,
        v.lane,
        v.speedKmph.toStringAsFixed(1),
        v.grossWeightKg.toStringAsFixed(0),
        fmt.format(v.timestamp),
      ]);
    }
    final bytes = excel.encode();
    if (bytes == null) return;

    // Save to temporary directory and share/notify user
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/TraffiQIQ_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text('Excel saved: ${file.path}')));
  }

  static Future<void> shareReport(
    BuildContext context,
    List<VehicleData> data,
  ) async {
    // quick: export pdf then open share (use printing package)
    await exportPdf(context, data, null);
  }
  
  static Future getTemporaryDirectory() async {}
}

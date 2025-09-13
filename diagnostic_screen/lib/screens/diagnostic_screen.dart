import 'package:flutter/material.dart';

class DiagnosticScreen extends StatelessWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Sensor Diagnostic')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DiagnosticTile(sensor: 'Strain Gauge', status: 'Working'),
            DiagnosticTile(
              sensor: 'Temperature Sensor',
              status: 'Not Detected',
            ),
            // Add more sensors here
          ],
        ),
      ),
    );
  }
}

class DiagnosticTile extends StatelessWidget {
  final String sensor;
  final String status;

  const DiagnosticTile({super.key, required this.sensor, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(sensor),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == 'Working' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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

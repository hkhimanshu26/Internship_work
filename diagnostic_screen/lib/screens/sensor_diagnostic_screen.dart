import 'package:flutter/material.dart';
import '../models/sensor_model.dart';
import '../services/firebase_service.dart';
import '../widgets/lane_view.dart';

class SensorDiagnosticScreen extends StatefulWidget {
  const SensorDiagnosticScreen({super.key});

  @override
  State<SensorDiagnosticScreen> createState() => _SensorDiagnosticScreenState();
}

class _SensorDiagnosticScreenState extends State<SensorDiagnosticScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  bool isRecording = false;
  bool isGraphView = true;

  void toggleRecording() => setState(() => isRecording = !isRecording);
  void switchView() => setState(() => isGraphView = !isGraphView);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Diagnostic')),
      body: Column(
        children: [
          // Top Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: toggleRecording,
                child: Text(isRecording ? 'Stop' : 'Start'),
              ),
              ElevatedButton(
                onPressed: switchView,
                child: Text(isGraphView ? 'Table View' : 'Graphical View'),
              ),
              ElevatedButton(
                onPressed: _raiseSupportDialog,
                child: const Text("Support"),
              ),
            ],
          ),
          // Live Data View
          Expanded(
            child: StreamBuilder<List<LaneData>>(
              stream: _firebaseService.streamSensorData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                return isGraphView
                    ? LaneView(lanes: data)
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, i) {
                          final lane = data[i];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text('Lane ${lane.laneNumber}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: lane.sensors
                                    .map(
                                      (s) => Text(
                                        '${s.label} (${s.type}) - ${s.count}',
                                      ),
                                    )
                                    .toList(),
                              ),
                              trailing: Text('Vehicles: ${lane.vehicleCount}'),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _raiseSupportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Raise Support Request"),
        content: const TextField(
          decoration: InputDecoration(hintText: "Describe issue..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("Submit")),
        ],
      ),
    );
  }
}

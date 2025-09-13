import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:traffiqiq_app/screen_navigation.dart';

class SensorDiagnosticScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SensorDiagnosticScreen({super.key, required this.toggleTheme});
  @override
  State<SensorDiagnosticScreen> createState() => _SensorDiagnosticScreenState();
}

class _SensorDiagnosticScreenState extends State<SensorDiagnosticScreen> {
  bool isGraphicalView = true;
  bool isStarted = false;
  Timer? _timer;

  final List<List<int>> sensorData = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];

  final List<List<int>> sensorCounts = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];

  final List<bool> laneDirections = [true, false, true];
  List<Map<String, dynamic>> dummyData = [];
  int dataPointer = 0;

  List<List<int>>? savedCounts;
  Map<String, dynamic>? currentVehicleInfo;

  int get totalVehicleCount => sensorCounts
      .map((lane) => lane.reduce((a, b) => a + b))
      .reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    loadDummyData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadDummyData() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/sample_data.json',
    );
    dummyData = List<Map<String, dynamic>>.from(jsonDecode(jsonStr));

    // Preload first snapshot
    for (var entry in dummyData) {
      int laneIndex = (entry['lane'] ?? 1) - 1;
      List axles = entry['axles'] ?? [];

      for (int i = 0; i < axles.length && i < 4; i++) {
        int weight = axles[i]['weight_kg'] ?? 0;
        sensorData[laneIndex][i] = weight;
        sensorCounts[laneIndex][i]++;
      }
    }

    if (dummyData.isNotEmpty) {
      currentVehicleInfo = dummyData.first;
    }

    setState(() {});
  }

  void startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (dummyData.isEmpty) return;

      for (int i = 0; i < sensorData.length; i++) {
        for (int j = 0; j < sensorData[i].length; j++) {
          sensorData[i][j] = 0;
        }
      }

      final entry = dummyData[dataPointer % dummyData.length];
      dataPointer++;

      currentVehicleInfo = entry;

      int laneIndex = (entry['lane'] ?? 1) - 1;
      List axles = entry['axles'] ?? [];

      for (int i = 0; i < axles.length && i < 4; i++) {
        int weight = axles[i]['weight_kg'] ?? 0;
        sensorData[laneIndex][i] = weight;
        sensorCounts[laneIndex][i]++;
      }

      setState(() {});
    });
  }

  void stopSimulation() {
    _timer?.cancel();
  }

  void showSupportDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raise Support Request'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe your issue here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final issue = controller.text.trim();
              if (issue.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support request submitted!')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void saveSensorCounts() {
    savedCounts = sensorCounts.map((lane) => List<int>.from(lane)).toList();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sensor data saved.')));
  }

  void recallSensorCounts() {
    if (savedCounts != null) {
      setState(() {
        for (int i = 0; i < sensorCounts.length; i++) {
          for (int j = 0; j < sensorCounts[i].length; j++) {
            sensorCounts[i][j] = savedCounts![i][j];
          }
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sensor data recalled.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Sensor Diagnostic'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TraffiQIQ Navigation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('Sensor Diagnostic'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AboutScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [isGraphicalView, !isGraphicalView],
            onPressed: (index) {
              setState(() {
                isGraphicalView = index == 0;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Graphical View'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Tabular View'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isGraphicalView ? buildGraphicalView() : buildTabularView(),
          ),
          if (currentVehicleInfo != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Info',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Vehicle ID: ${currentVehicleInfo!['vehicle_id']}'),
                      Text('Class: ${currentVehicleInfo!['vehicle_class']}'),
                      Text('Lane: ${currentVehicleInfo!['lane']}'),
                      Text('Speed: ${currentVehicleInfo!['speed_kmph']} km/h'),
                      Text(
                        'Gross Weight: ${currentVehicleInfo!['gross_weight_kg']} kg',
                      ),
                      Text('Axles: ${currentVehicleInfo!['axle_count']}'),
                      Text(
                        'Overloaded: ${currentVehicleInfo!['overloaded'] ? "Yes" : "No"}',
                      ),
                      Text(
                        'Confidence: ${(currentVehicleInfo!['confidence'] * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  isStarted = !isStarted;
                  if (isStarted) {
                    startSimulation();
                  } else {
                    stopSimulation();
                  }
                });
              },
              label: Text(isStarted ? 'Stop' : 'Start'),
              icon: Icon(isStarted ? Icons.pause : Icons.play_arrow),
            ),
            FloatingActionButton.extended(
              onPressed: showSupportDialog,
              label: const Text('Support'),
              icon: const Icon(Icons.support_agent),
            ),
            FloatingActionButton.extended(
              onPressed: saveSensorCounts,
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
            FloatingActionButton.extended(
              onPressed: recallSensorCounts,
              label: const Text('Recall'),
              icon: const Icon(Icons.history),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGraphicalView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sensorData.length,
            itemBuilder: (context, laneIndex) {
              final lane = sensorData[laneIndex];
              final counts = sensorCounts[laneIndex];
              final direction = laneDirections[laneIndex] ? '➡️' : '⬅️';
              final isRight = laneDirections[laneIndex];
              final laneTotal = counts.reduce((a, b) => a + b);

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lane ${laneIndex + 1} $direction  |  Total Vehicles: $laneTotal',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: isRight
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: List.generate(4, (sensorIndex) {
                        final int weight = lane[sensorIndex]; // kg
                        final double height = min(
                          weight / 100.0,
                          120,
                        ); // scale max 120
                        final barColor = sensorIndex == 0 || sensorIndex == 2
                            ? Colors.green
                            : sensorIndex == 1
                            ? Colors.blue
                            : Colors.orange;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: height,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('S${sensorIndex + 1}'),
                              Text('${counts[sensorIndex]}'),
                            ],
                          ),
                        );
                      }).reversed.toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Vehicle Count: $totalVehicleCount',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Row(
                children: [
                  _LegendItem(color: Colors.green, label: 'Loop Sensor'),
                  SizedBox(width: 16),
                  _LegendItem(color: Colors.blue, label: 'Piezo Sensor'),
                  SizedBox(width: 16),
                  _LegendItem(color: Colors.orange, label: 'Special Sensor'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTabularView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.grey),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Lane'),
                  ),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('S${i + 1}'),
                    ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Total'),
                  ),
                ],
              ),
              for (int i = 0; i < sensorData.length; i++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Lane ${i + 1}'),
                    ),
                    for (int j = 0; j < 4; j++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${sensorCounts[i][j]}'),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${sensorCounts[i].reduce((a, b) => a + b)}'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Vehicle Count: $totalVehicleCount',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    _LegendItem(color: Colors.green, label: 'Loop Sensor'),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.blue, label: 'Piezo Sensor'),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.orange, label: 'Special Sensor'),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sensor_diagnostic_screen_v3/widgets/data_table_widget.dart';
import 'package:sensor_diagnostic_screen_v3/widgets/graph_widget.dart';
import 'package:sensor_diagnostic_screen_v3/widgets/raise_support_dialog.dart';
import 'package:sensor_diagnostic_screen_v3/widgets/start_stop_buttons.dart';
import 'models/vehicle_data_model.dart';
import 'package:flutter/material.dart';

class SensorDiagnosticScreenV3 extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SensorDiagnosticScreenV3({super.key, required this.onToggleTheme});

  @override
  State<SensorDiagnosticScreenV3> createState() =>
      _SensorDiagnosticScreenV3State();
}

class _SensorDiagnosticScreenV3State extends State<SensorDiagnosticScreenV3> {
  int _currentIndex = 0;
  Timer? _simulationTimer;
  List<VehicleData> allVehicleData = [];

  bool isGraphicalView = false;
  bool isStarted = false;
  List<VehicleData> snapshot = [];
  bool isViewingSnapshot = false;
  List<VehicleData> vehicles = [];
  List<VehicleData> fullJsonData = [];

  @override
  void initState() {
    super.initState();
    loadVehicleData();
  }

  Future<void> loadVehicleData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/vehicle_data.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    allVehicleData = jsonList.map((e) => VehicleData.fromJson(e)).toList();
  }

  void startSimulation() {
    _simulationTimer?.cancel(); // Clear existing timer if any
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        vehicles.add(allVehicleData[_currentIndex]);
      });

      _currentIndex++;

      // Loop the simulation
      if (_currentIndex >= allVehicleData.length) {
        _currentIndex = 0; // 👈 Start again from the beginning
      }
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      isStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/traffiqiq_logo.png', height: 32),
            const SizedBox(width: 12),
            Text(
              "Sensor Diagnostic",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme,
              tooltip: "Toggle Theme",
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/traffiqiq_logo.png', height: 48),
                  const SizedBox(height: 8),
                  Text(
                    "TraffiQIQ",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Device'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// TOP CONTROL BUTTONS (Wrapped in Scroll for safety)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StartStopButtons(
                        isStarted: isStarted,
                        onStartPressed: () {
                          if (isStarted) {
                            stopSimulation();
                          } else {
                            vehicles.clear(); // Optional: reset display
                            _currentIndex = 0;
                            startSimulation();
                          }

                          setState(() {
                            isStarted = !isStarted;
                          });
                        },
                        onStopPressed: () {
                          setState(() {
                            isStarted = false;
                          });
                          stopSimulation();
                        },
                      ),

                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Save Snapshot"),
                        onPressed: () {
                          if (vehicles.isNotEmpty) {
                            setState(() {
                              snapshot = List<VehicleData>.from(vehicles);
                              isViewingSnapshot = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Snapshot saved successfully.'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.history),
                        label: const Text("Recall Snapshot"),
                        onPressed: () {
                          if (snapshot.isNotEmpty) {
                            setState(() {
                              vehicles = List<VehicleData>.from(snapshot);
                              isViewingSnapshot = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.support_agent),
                        label: const Text("Raise Support"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const RaiseSupportDialog(),
                          );
                        },
                      ),

                      const SizedBox(width: 8),
                      ToggleButtons(
                        isSelected: [!isGraphicalView, isGraphicalView],
                        onPressed: (index) {
                          setState(() {
                            isGraphicalView = index == 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("Tabular View"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("Graph View"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// SNAPSHOT INFO
                if (isViewingSnapshot)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          "Viewing snapshot data",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                  ),

                /// MAIN DISPLAY AREA
                Expanded(
                  child: isGraphicalView
                      ? GraphWidget(vehicles: vehicles)
                      : vehicles.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : DataTableWidget(vehicles: vehicles),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

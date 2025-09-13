import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_diagnostic_screen_v2/main.dart';

class SensorDiagnosticScreenV2 extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SensorDiagnosticScreenV2({super.key, required this.toggleTheme});

  @override
  State<SensorDiagnosticScreenV2> createState() =>
      _SensorDiagnosticScreenV2State();
}

class _SensorDiagnosticScreenV2State extends State<SensorDiagnosticScreenV2>
    with TickerProviderStateMixin {
  bool isStarted = false;
  Timer? _timer;

  final List<List<int>> sensorData = List.generate(3, (_) => List.filled(4, 0));
  final List<List<int>> sensorCounts = List.generate(
    3,
    (_) => List.filled(4, 0),
  );
  final List<bool> laneDirections = [true, false, true];
  List<Map<String, dynamic>> dummyData = [];
  int dataPointer = 0;
  Map<String, dynamic>? currentVehicleInfo;
  List<List<int>>? savedCounts;

  late TabController _tabController;

  int get totalVehicleCount => sensorCounts
      .map((lane) => lane.reduce((a, b) => a + b))
      .reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadDummyData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadDummyData() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/sample_data.json',
    );
    dummyData = List<Map<String, dynamic>>.from(jsonDecode(jsonStr));

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
          decoration: const InputDecoration(hintText: 'Describe your issue...'),
        ),
        actions: [
          HoverButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          HoverButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
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
        title: const Text('Sensor Diagnostic V2'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Graphical'),
            Tab(text: 'Tabular'),
          ],
        ),
      ),
      drawer: AppDrawer(toggleTheme: widget.toggleTheme), // Drawer added here
      body: Column(
        children: [
          const SensorLegendWidget(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildGraphicalView(), _buildTabularView()],
            ),
          ),
          if (currentVehicleInfo != null) _buildVehicleInfoCard(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 10,
          runSpacing: 10,
          children: [
            HoverButton.icon(
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
              icon: Icon(isStarted ? Icons.pause : Icons.play_arrow),
              label: Text(isStarted ? 'Stop' : 'Start'),
            ),
            HoverButton.icon(
              onPressed: showSupportDialog,
              icon: const Icon(Icons.support_agent),
              label: const Text('Support'),
            ),
            HoverButton.icon(
              onPressed: saveSensorCounts,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            HoverButton.icon(
              onPressed: recallSensorCounts,
              icon: const Icon(Icons.history),
              label: const Text('Recall'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphicalView() {
    return ListView.builder(
      itemCount: sensorData.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, laneIndex) {
        final lane = sensorData[laneIndex];
        final counts = sensorCounts[laneIndex];
        final direction = laneDirections[laneIndex] ? '➡️' : '⬅️';
        final laneTotal = counts.reduce((a, b) => a + b);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lane ${laneIndex + 1} $direction | Total Vehicles: $laneTotal',
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: laneDirections[laneIndex]
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: List.generate(4, (i) {
                    double height = min(lane[i] / 100, 120);
                    Color barColor = i == 0 || i == 2
                        ? Colors.green
                        : i == 1
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('S${i + 1}'),
                          Text('${counts[i]}'),
                        ],
                      ),
                    );
                  }).reversed.toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabularView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3: FlexColumnWidth(),
          4: FlexColumnWidth(),
          5: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text('Lane')),
              Padding(padding: EdgeInsets.all(8), child: Text('S1')),
              Padding(padding: EdgeInsets.all(8), child: Text('S2')),
              Padding(padding: EdgeInsets.all(8), child: Text('S3')),
              Padding(padding: EdgeInsets.all(8), child: Text('S4')),
              Padding(padding: EdgeInsets.all(8), child: Text('Total')),
            ],
          ),
          for (int i = 0; i < sensorCounts.length; i++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Lane ${i + 1}'),
                ),
                for (int j = 0; j < 4; j++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('${sensorCounts[i][j]}'),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${sensorCounts[i].reduce((a, b) => a + b)}'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    final info = currentVehicleInfo!;
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Info',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ID: ${info['vehicle_id']}'),
            Text('Class: ${info['vehicle_class']}'),
            Text('Lane: ${info['lane']}'),
            Text('Speed: ${info['speed_kmph']} km/h'),
            Text('Gross Weight: ${info['gross_weight_kg']} kg'),
            Text('Axles: ${info['axle_count']}'),
            Text('Overloaded: ${info['overloaded'] ? 'Yes' : 'No'}'),
            Text(
              'Confidence: ${(info['confidence'] * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}

class HoverButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const HoverButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: child,
    );
  }

  static Widget icon({
    required VoidCallback onPressed,
    required Icon icon,
    required Text label,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  const AppDrawer({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                Image.asset('assets/images/traffiqiq_logo.png', height: 80),
                const SizedBox(height: 10),
                const Text(
                  'TraffiQIQ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                  builder: (context) => HomeScreen(toggleTheme: toggleTheme),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(toggleTheme: toggleTheme),
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
                      SettingsScreen(toggleTheme: toggleTheme),
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
                  builder: (context) => AboutScreen(toggleTheme: toggleTheme),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Sensor Diagnostics'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Toggle Theme'),
            onTap: () {
              Navigator.pop(context);
              toggleTheme(); // 🌗 Toggle theme here
            },
          ),
        ],
      ),
    );
  }
}

class SensorLegendWidget extends StatelessWidget {
  const SensorLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: MediaQuery.of(context).size.width * 0.04,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: const [
          SensorLegendItem(
            color: Colors.blue,
            label: "Loop Sensor",
            icon: Icons.sensors,
          ),
          SensorLegendItem(
            color: Colors.red,
            label: "Piezo Sensor",
            icon: Icons.sensors_off,
          ),
          SensorLegendItem(
            color: Colors.green,
            label: "Working",
            icon: Icons.check_circle,
          ),
          SensorLegendItem(
            color: Colors.grey,
            label: "Inactive",
            icon: Icons.remove_circle,
          ),
        ],
      ),
    );
  }
}

class SensorLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const SensorLegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

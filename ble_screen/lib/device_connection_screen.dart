import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen>
    with SingleTickerProviderStateMixin {
  List<ScanResult> devices = [];
  List<BluetoothDevice> connectedDevices = [];
  bool scanning = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, String>> demoDevices = [
    {"name": "TraffiQIQ Sensor", "id": "00:11:22:33:44:55"},
    {"name": "WeighBridge Pro", "id": "11:22:33:44:55:66"},
    {"name": "LoopSensorX", "id": "22:33:44:55:66:77"},
    {"name": "PiezoTrack-01", "id": "33:44:55:66:77:88"},
  ];

  @override
  void initState() {
    super.initState();
    startScan();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Load already connected devices
    FlutterBluePlus.connectedDevices.then((value) {
      setState(() {
        connectedDevices = value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startScan() {
    setState(() {
      devices.clear();
      scanning = true;
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results;
      });
    });

    FlutterBluePlus.isScanning.listen((isScanning) {
      setState(() {
        scanning = isScanning;
      });
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    setState(() => scanning = false);

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      if (!e.toString().contains("already connected")) rethrow;
    }

    if (!connectedDevices.contains(device)) {
      setState(() => connectedDevices.add(device));
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> availableDevices = [
      ...devices.map<Map<String, dynamic>>(
        (d) => {
          "name": d.device.platformName.isNotEmpty
              ? d.device.platformName
              : "Unknown Device",
          "id": d.device.remoteId.str,
          "device": d.device,
          "isDemo": false,
        },
      ),
      ...demoDevices.map<Map<String, dynamic>>(
        (d) => {
          "name": d["name"]!,
          "id": d["id"]!,
          "device": null,
          "isDemo": true,
        },
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Device Connection"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// Animated Bluetooth Icon
          ScaleTransition(
            scale: _animation,
            child: Icon(
              Icons.bluetooth,
              size: 90,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scanning ? "Scanning for devices..." : "Available Devices",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          if (scanning) const LinearProgressIndicator(minHeight: 3),

          const Divider(height: 30),

          /// Connected Devices Section
          if (connectedDevices.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Connected Devices",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: connectedDevices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dev = connectedDevices[index];
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    dev.platformName.isNotEmpty
                        ? dev.platformName
                        : "Unknown Device",
                  ),
                  subtitle: Text(dev.remoteId.str),
                  trailing: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/main'),
                    child: const Text("Open"),
                  ),
                );
              },
            ),
            const Divider(height: 30),
          ],

          /// Available Devices Section
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableDevices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dev = availableDevices[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.devices_other,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    dev["name"] ?? "Unknown Device",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(dev["id"] ?? ""),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    onPressed: dev["isDemo"] == true
                        ? () => Navigator.pushReplacementNamed(context, '/main')
                        : () =>
                              connectToDevice(dev["device"] as BluetoothDevice),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
          ),

          /// Bottom Rescan Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: scanning ? null : startScan,
              icon: const Icon(Icons.refresh),
              label: const Text("Rescan"),
            ),
          ),
        ],
      ),
    );
  }
}

extension on List<BluetoothDevice> {
  void then(Null Function(dynamic value) param0) {}
}

import 'package:flutter/material.dart';
import '../models/vehicle_data_model.dart';
import '../widgets/lane_colors.dart';
import '../widgets/vehicle_info_card.dart'; // Import the card widget

class DataTableWidget extends StatefulWidget {
  final List<VehicleData> vehicles;

  const DataTableWidget({super.key, required this.vehicles});

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

int _savedPageIndex = 0;
int _savedRowsPerPage = 5;

class _DataTableWidgetState extends State<DataTableWidget> {
  late int _rowsPerPage;
  late int _pageIndex;

  String? selectedLane;
  String? selectedClass;
  String? selectedOverload;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = _savedRowsPerPage;
    _pageIndex = _savedPageIndex;
  }

  List<VehicleData> get filteredVehicles {
    return widget.vehicles.where((vehicle) {
      final laneMatch =
          selectedLane == null || vehicle.lane.toString() == selectedLane;
      final classMatch =
          selectedClass == null || vehicle.vehicleClass == selectedClass;
      final overloadMatch =
          selectedOverload == null ||
          (selectedOverload == "Yes" && vehicle.overloaded) ||
          (selectedOverload == "No" && !vehicle.overloaded);
      return laneMatch && classMatch && overloadMatch;
    }).toList();
  }

  void _showVehicleInfo(VehicleData vehicle) {
    showDialog(
      context: context,
      builder: (_) => VehicleInfoCard(
        vehicle: vehicle,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<int, Map<String, int>> laneSensorCounts = {};
    final Map<int, int> laneVehicleCounts = {};

    for (var vehicle in widget.vehicles) {
      int lane = vehicle.lane;
      laneSensorCounts.putIfAbsent(
        lane,
        () => {'L1': 0, 'L2': 0, 'S1': 0, 'S2': 0},
      );

      if (vehicle.axleCount % 2 == 0) {
        laneSensorCounts[lane]!['L1'] = laneSensorCounts[lane]!['L1']! + 1;
        laneSensorCounts[lane]!['S1'] = laneSensorCounts[lane]!['S1']! + 1;
      } else {
        laneSensorCounts[lane]!['L2'] = laneSensorCounts[lane]!['L2']! + 1;
        laneSensorCounts[lane]!['S2'] = laneSensorCounts[lane]!['S2']! + 1;
      }
      laneVehicleCounts[lane] = (laneVehicleCounts[lane] ?? 0) + 1;
    }

    final sortedLanes = laneSensorCounts.keys.toList()..sort();

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  DropdownButton<String>(
                    hint: const Text("Filter by Lane"),
                    value: selectedLane,
                    items: [
                      ...sortedLanes.map(
                        (lane) => DropdownMenuItem(
                          value: lane.toString(),
                          child: Text("Lane $lane"),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Lanes"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedLane = value);
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text("Filter by Class"),
                    value: selectedClass,
                    items: [
                      ...widget.vehicles
                          .map((v) => v.vehicleClass)
                          .toSet()
                          .map(
                            (cls) =>
                                DropdownMenuItem(value: cls, child: Text(cls)),
                          ),
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Classes"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedClass = value);
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text("Overloaded?"),
                    value: selectedOverload,
                    items: const [
                      DropdownMenuItem(value: "Yes", child: Text("Yes")),
                      DropdownMenuItem(value: "No", child: Text("No")),
                      DropdownMenuItem(value: null, child: Text("All")),
                    ],
                    onChanged: (value) {
                      setState(() => selectedOverload = value);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedLane = null;
                        selectedClass = null;
                        selectedOverload = null;
                      });
                    },
                    child: const Text("Reset Filters"),
                  ),
                ],
              ),
            ),

            /// Lane Color Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(spacing: 12, children: LaneColors.buildLaneLegends()),
            ),

            /// Summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lane-wise Sensor & Vehicle Counts",
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...sortedLanes.map((lane) {
                    final sensors = laneSensorCounts[lane]!;
                    final vehicleCount = laneVehicleCounts[lane] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Lane $lane → "
                        "L1: ${sensors['L1']}, L2: ${sensors['L2']}, "
                        "S1: ${sensors['S1']}, S2: ${sensors['S2']} | "
                        "Vehicles: $vehicleCount",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            /// Paginated Table
            PaginatedDataTable(
              header: const Text('Vehicle Data'),
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage: const [5, 10, 20],
              onRowsPerPageChanged: (value) {
                if (value != null) {
                  setState(() {
                    _rowsPerPage = value;
                    _savedRowsPerPage = value;
                  });
                }
              },
              initialFirstRowIndex: _pageIndex * _rowsPerPage,
              onPageChanged: (rowIndex) {
                setState(() {
                  _pageIndex = rowIndex ~/ _rowsPerPage;
                  _savedPageIndex = _pageIndex;
                });
              },
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Speed')),
                DataColumn(label: Text('Weight')),
                DataColumn(label: Text('Axles')),
                DataColumn(label: Text('Lane')),
                DataColumn(label: Text('Overloaded')),
              ],
              source: _VehicleDataSource(
                filteredVehicles,
                onVehicleTap: _showVehicleInfo,
              ),
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDataSource extends DataTableSource {
  final List<VehicleData> vehicles;
  final Function(VehicleData) onVehicleTap;

  _VehicleDataSource(this.vehicles, {required this.onVehicleTap});

  @override
  DataRow? getRow(int index) {
    if (index >= vehicles.length) return null;
    final vehicle = vehicles[index];
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (states) => index.isEven
            ? Colors.grey.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      cells: [
        DataCell(
          InkWell(
            onTap: () => onVehicleTap(vehicle),
            child: Text(
              vehicle.vehicleId,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        DataCell(Text(vehicle.vehicleClass)),
        DataCell(Text('${vehicle.speedKmph.toStringAsFixed(1)} km/h')),
        DataCell(Text('${vehicle.grossWeightKg} kg')),
        DataCell(Text('${vehicle.axleCount}')),

        /// Lane cell with lane-colored badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: LaneColors.getLaneColor(
                vehicle.lane,
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${vehicle.lane}',
              style: TextStyle(
                color: LaneColors.getLaneColor(vehicle.lane),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        DataCell(
          Icon(
            vehicle.overloaded ? Icons.warning : Icons.check_circle,
            color: vehicle.overloaded ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => vehicles.length;
  @override
  int get selectedRowCount => 0;
}
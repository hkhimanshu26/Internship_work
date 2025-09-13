import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/vehicle_data_model.dart';
import 'vehicle_info_card.dart';

class GraphWidget extends StatefulWidget {
  final List<VehicleData> vehicles;

  const GraphWidget({super.key, required this.vehicles});

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  String? selectedSensor;
  int? selectedLane;
  String? selectedVehicleId;
  bool showInfoCard = false;
  bool showPopup = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<int, Map<String, int>> laneSensorCounts = {};
    final Map<int, int> laneVehicleCount = {};

    for (var vehicle in widget.vehicles) {
      laneSensorCounts.putIfAbsent(
        vehicle.lane,
        () => {'L1': 0, 'L2': 0, 'S1': 0, 'S2': 0},
      );

      laneVehicleCount[vehicle.lane] =
          (laneVehicleCount[vehicle.lane] ?? 0) + 1;

      if (vehicle.axleCount % 2 == 0) {
        laneSensorCounts[vehicle.lane]!['L1'] =
            laneSensorCounts[vehicle.lane]!['L1']! + 1;
        laneSensorCounts[vehicle.lane]!['S1'] =
            laneSensorCounts[vehicle.lane]!['S1']! + 1;
      } else {
        laneSensorCounts[vehicle.lane]!['L2'] =
            laneSensorCounts[vehicle.lane]!['L2']! + 1;
        laneSensorCounts[vehicle.lane]!['S2'] =
            laneSensorCounts[vehicle.lane]!['S2']! + 1;
      }
    }

    final barGroups = laneSensorCounts.entries.map((entry) {
      final lane = entry.key;
      final sensors = entry.value;

      return BarChartGroupData(
        x: lane,
        barRods: [
          BarChartRodData(
            toY: sensors['L1']!.toDouble(),
            width: 8,
            color: Colors.blue,
          ),
          BarChartRodData(
            toY: sensors['L2']!.toDouble(),
            width: 8,
            color: Colors.green,
          ),
          BarChartRodData(
            toY: sensors['S1']!.toDouble(),
            width: 8,
            color: Colors.orange,
          ),
          BarChartRodData(
            toY: sensors['S2']!.toDouble(),
            width: 8,
            color: Colors.purple,
          ),
        ],
        showingTooltipIndicators: [0, 1, 2, 3],
        barsSpace: 4,
      );
    }).toList();

    final filteredVehicles = widget.vehicles.where((v) {
      return selectedLane != null &&
          selectedSensor != null &&
          v.lane == selectedLane;
    }).toList();

    final vehicleIdsForSelected = filteredVehicles
        .map((v) => v.vehicleId)
        .toSet()
        .toList();

    final selectedVehicle = selectedVehicleId == null
        ? null
        : widget.vehicles.firstWhere(
            (v) => v.vehicleId == selectedVehicleId,
            orElse: () => VehicleData.empty(),
          );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sensor Count by Lane", style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    maxY: 10,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Lane ${value.toInt()}'),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      ),
                    ),
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (event.isInterestedForInteractions &&
                            response != null &&
                            response.spot != null) {
                          final lane = response.spot!.touchedBarGroup.x;
                          final rodIndex = response.spot!.touchedRodDataIndex;
                          final sensorLabels = ['L1', 'L2', 'S1', 'S2'];
                          setState(() {
                            selectedLane = lane;
                            selectedSensor = sensorLabels[rodIndex];
                            selectedVehicleId = null;
                            showInfoCard = true;
                            showPopup = true;
                          });
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.grey.shade200,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final sensorLabels = ['L1', 'L2', 'S1', 'S2'];
                          return BarTooltipItem(
                            '${sensorLabels[rodIndex]}: ${rod.toY.toInt()}',
                            TextStyle(color: theme.colorScheme.primary),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 16,
                children: [
                  _buildLegend("L1", Colors.blue),
                  _buildLegend("L2", Colors.green),
                  _buildLegend("S1", Colors.orange),
                  _buildLegend("S2", Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "Sensor Summary per Lane",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...laneSensorCounts.entries.map((entry) {
                final lane = entry.key;
                final sensors = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Lane $lane → L1: ${sensors['L1']}, L2: ${sensors['L2']}, S1: ${sensors['S1']}, S2: ${sensors['S2']}",
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }),

              const SizedBox(height: 24),

              Text(
                "Vehicle Count per Lane",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...laneVehicleCount.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("Lane ${entry.key}: ${entry.value} vehicles"),
                );
              }),
            ],
          ),
        ),

        if (showPopup)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showPopup = false;
                  selectedVehicleId = null;
                  selectedLane = null;
                  selectedSensor = null;
                  showInfoCard = false;
                });
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),

        if (showPopup)
          Positioned(
            left: 20,
            top: 150,
            right: 20,
            child: AnimatedScale(
              scale: showPopup ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: showPopup ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: theme.cardColor,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: selectedVehicleId == null
                            ? (vehicleIdsForSelected.isEmpty
                                  ? Text(
                                      "No vehicles found.",
                                      style: theme.textTheme.bodyMedium,
                                    )
                                  : SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: vehicleIdsForSelected.map((
                                          id,
                                        ) {
                                          return ChoiceChip(
                                            label: Text(id),
                                            selected: false,
                                            onSelected: (_) {
                                              setState(() {
                                                selectedVehicleId = id;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          setState(() {
                                            selectedVehicleId = null;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Vehicle Details",
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: VehicleInfoCard(
                                        vehicle: selectedVehicle!,
                                        onClose: () {
                                          setState(() {
                                            selectedVehicleId = null;
                                            showPopup = false;
                                            selectedLane = null;
                                            selectedSensor = null;
                                            showInfoCard = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (selectedVehicleId == null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                showPopup = false;
                                selectedLane = null;
                                selectedSensor = null;
                                showInfoCard = false;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

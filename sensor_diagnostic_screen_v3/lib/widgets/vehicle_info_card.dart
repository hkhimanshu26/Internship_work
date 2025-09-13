import 'package:flutter/material.dart';
import '../models/vehicle_data_model.dart';

class VehicleInfoCard extends StatelessWidget {
  final VehicleData vehicle;
  final VoidCallback onClose;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final cardWidth = isMobile
        ? MediaQuery.of(context).size.width - 32
        : MediaQuery.of(context).size.width * 0.5;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: theme.cardColor.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: cardWidth,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vehicle Information",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
              const Divider(),

              /// Main Info Row
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      vehicle.overloaded
                          ? Icons.warning_amber_rounded
                          : Icons.directions_car,
                      color: vehicle.overloaded
                          ? Colors.red
                          : theme.colorScheme.secondary,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoLine("Vehicle ID", vehicle.vehicleId),
                          _infoLine("Class", vehicle.vehicleClass),
                          _infoLine(
                            "Speed",
                            "${vehicle.speedKmph.toStringAsFixed(1)} km/h",
                          ),
                          _infoLine("Weight", "${vehicle.grossWeightKg} kg"),
                          _infoLine("Axles", "${vehicle.axleCount}"),
                          _infoLine("Lane", "${vehicle.lane}"),
                          _infoLine(
                            "Overloaded",
                            vehicle.overloaded ? "Yes" : "No",
                          ),
                          _infoLine(
                            "Confidence",
                            "${(vehicle.confidence * 100).toStringAsFixed(1)}%",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

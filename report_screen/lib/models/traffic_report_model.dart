import 'package:flutter/material.dart';

enum VehicleClass { car, truck, bus, other }

class TrafficReport {
  final DateTime dateTime; // hour timestamp (or any period bucket)
  final String location; // "Main Street", "Highway 101", etc.
  final int trafficVolume; // vehicles counted in this bucket
  final double averageSpeedMph; // avg speed for bucket
  final int violations; // use as overloaded/violations count
  final String status; // "Normal" | "Warning" | "Critical"
  final VehicleClass vehicleClass;

  const TrafficReport({
    required this.dateTime,
    required this.location,
    required this.trafficVolume,
    required this.averageSpeedMph,
    required this.violations,
    required this.status,
    required this.vehicleClass,
  });
}

/// Compact KPI summary for the header cards.
class ReportSummary {
  final int totalVehicles;
  final double averageSpeedMph;
  final int overloadedVehicles;
  final TimeOfDay? peakHour; // null if data empty

  const ReportSummary({
    required this.totalVehicles,
    required this.averageSpeedMph,
    required this.overloadedVehicles,
    required this.peakHour,
  });
}

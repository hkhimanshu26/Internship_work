import 'dart:convert';

class Axle {
  final int axleNumber;
  final double weightKg;
  final int axleDistanceCm;

  Axle({
    required this.axleNumber,
    required this.weightKg,
    required this.axleDistanceCm,
  });

  factory Axle.fromMap(Map<String, dynamic> m) => Axle(
    axleNumber: m['axle_number'] as int,
    weightKg: (m['weight_kg'] as num).toDouble(),
    axleDistanceCm: (m['axle_distance_cm'] as num).toInt(),
  );
}

class VehicleData {
  final String deviceId;
  final int lane;
  final DateTime timestamp;
  final String vehicleId;
  final String vehicleClass;
  final int axleCount;
  final double grossWeightKg;
  final List<Axle> axles;
  final double speedKmph;
  final bool overloaded;
  final double confidence;

  VehicleData({
    required this.deviceId,
    required this.lane,
    required this.timestamp,
    required this.vehicleId,
    required this.vehicleClass,
    required this.axleCount,
    required this.grossWeightKg,
    required this.axles,
    required this.speedKmph,
    required this.overloaded,
    required this.confidence,
  });

  factory VehicleData.fromMap(Map<String, dynamic> m) => VehicleData(
    deviceId: m['device_id'] as String,
    lane: (m['lane'] as num).toInt(),
    timestamp: DateTime.parse(m['timestamp'] as String).toLocal(),
    vehicleId: m['vehicle_id'] as String,
    vehicleClass: m['vehicle_class'] as String,
    axleCount: (m['axle_count'] as num).toInt(),
    grossWeightKg: (m['gross_weight_kg'] as num).toDouble(),
    axles: (m['axles'] as List<dynamic>)
        .map((e) => Axle.fromMap(e as Map<String, dynamic>))
        .toList(),
    speedKmph: (m['speed_kmph'] as num).toDouble(),
    overloaded: m['overloaded'] as bool,
    confidence: (m['confidence'] as num).toDouble(),
  );

  static List<VehicleData> listFromJson(String jsonString) {
    final arr = json.decode(jsonString) as List<dynamic>;
    return arr
        .map((e) => VehicleData.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

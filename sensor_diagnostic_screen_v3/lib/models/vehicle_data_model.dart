class Axle {
  final int axleNumber;
  final int weightKg;
  final int axleDistanceCm;

  Axle({
    required this.axleNumber,
    required this.weightKg,
    required this.axleDistanceCm,
  });

  factory Axle.fromJson(Map<String, dynamic> json) {
    return Axle(
      axleNumber: json['axle_number'],
      weightKg: json['weight_kg'],
      axleDistanceCm: json['axle_distance_cm'],
    );
  }
}

class VehicleData {
  final String deviceId;
  final int lane;
  final DateTime timestamp;
  final String vehicleId;
  final String vehicleClass;
  final int axleCount;
  final double speedKmph;
  final int grossWeightKg;
  final bool overloaded;
  final double confidence;
  final List<Axle> axles;
  final int vehicleCount; // Default value for vehicle count

  VehicleData({
    required this.deviceId,
    required this.lane,
    required this.timestamp,
    required this.vehicleId,
    required this.vehicleClass,
    required this.axleCount,
    required this.speedKmph,
    required this.grossWeightKg,
    required this.overloaded,
    required this.confidence,
    required this.axles,
    required this.vehicleCount,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    var axlesFromJson = json['axles'] as List<dynamic>;
    List<Axle> axleList = axlesFromJson.map((e) => Axle.fromJson(e)).toList();

    return VehicleData(
      deviceId: json['device_id'],
      lane: json['lane'],
      timestamp: DateTime.parse(json['timestamp']),
      vehicleId: json['vehicle_id'],
      vehicleClass: json['vehicle_class'],
      axleCount: json['axle_count'],
      speedKmph: json['speed_kmph'].toDouble(),
      grossWeightKg: json['gross_weight_kg'],
      overloaded: json['overloaded'],
      confidence: json['confidence'].toDouble(),
      vehicleCount:
          json['vehicleCount'] ?? 1, // Ensure vehicleCount is always present
      axles: axleList,
    );
  }

  static empty() {}
}

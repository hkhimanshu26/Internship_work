class SensorData {
  final String label;
  final int count;
  final String type;

  SensorData({required this.label, required this.count, required this.type});

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      label: map['label'],
      count: map['count'],
      type: map['type'],
    );
  }
}

class LaneData {
  final int laneNumber;
  final List<SensorData> sensors;
  final int vehicleCount;

  LaneData({
    required this.laneNumber,
    required this.sensors,
    required this.vehicleCount,
  });

  factory LaneData.fromMap(Map<String, dynamic> map) {
    List<SensorData> sensors = List<Map<String, dynamic>>.from(
      map['sensors'],
    ).map((e) => SensorData.fromMap(e)).toList();
    return LaneData(
      laneNumber: map['lane'],
      sensors: sensors,
      vehicleCount: map['vehicles'],
    );
  }
}

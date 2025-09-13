import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_model.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<List<LaneData>> getSensorData() async {
    final snapshot = await _db.collection('sensor_data').get();
    return snapshot.docs.map((doc) => LaneData.fromMap(doc.data())).toList();
  }

  Stream<List<LaneData>> streamSensorData() {
    return _db
        .collection('sensor_data')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => LaneData.fromMap(doc.data())).toList(),
        );
  }
}

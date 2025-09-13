import 'package:flutter/material.dart';
import '../models/sensor_model.dart';

class LaneView extends StatelessWidget {
  final List<LaneData> lanes;

  const LaneView({super.key, required this.lanes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lanes.length,
      itemBuilder: (context, index) {
        final lane = lanes[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lane ${lane.laneNumber}  →  ',
              style: TextStyle(fontSize: 16),
            ),
            ...lane.sensors.map(
              (sensor) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(sensor.label, style: TextStyle(color: Colors.white)),
                      Text(
                        '${sensor.count}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '🚗 ${lane.vehicleCount}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

/// Centralized lane color mapping for consistency
class LaneColors {
  static const Map<int, Color> laneColorMap = {
    1: Colors.blue,
    2: Colors.green,
    3: Colors.orange,
    4: Colors.purple,
    5: Colors.red,
    6: Colors.teal,
  };

  /// Get lane color with fallback
  static Color getLaneColor(int lane) {
    return laneColorMap[lane] ??
        Colors.grey; // Default color if lane not in map
  }

  /// Generate legend widget list
  static List<Widget> buildLaneLegends() {
    return laneColorMap.entries.map((entry) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: entry.value),
          const SizedBox(width: 4),
          Text("Lane ${entry.key}"),
        ],
      );
    }).toList();
  }
}

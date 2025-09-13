import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_data_model.dart';

class ReportKpiCards extends StatelessWidget {
  final List<VehicleData> data;
  const ReportKpiCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.length;
    final avgSpeed = total == 0
        ? 0.0
        : data.map((e) => e.speedKmph).reduce((a, b) => a + b) / total;
    final avgWeight = total == 0
        ? 0.0
        : data.map((e) => e.grossWeightKg).reduce((a, b) => a + b) / total;

    // Count per lane
    final laneCounts = <int, int>{};
    for (final v in data) {
      laneCounts[v.lane] = (laneCounts[v.lane] ?? 0) + 1;
    }

    final nf = NumberFormat.compact();

    final items = [
      _KpiItem(
        title: 'Total Vehicles',
        value: nf.format(total),
        subtitle: 'Records',
        icon: Icons.directions_car, // 🚗
      ),
      _KpiItem(
        title: 'Avg Speed',
        value: '${avgSpeed.toStringAsFixed(1)} km/h',
        subtitle: 'Mean speed',
        icon: Icons.speed, // ⚡
      ),
      _KpiItem(
        title: 'Avg Weight',
        value: '${(avgWeight / 1000).toStringAsFixed(2)} t',
        subtitle: 'Mean gross weight',
        icon: Icons.scale, // ⚖
      ),
      _KpiItem(
        title: 'Lane Dist.',
        value: laneCounts.entries
            .map((e) => 'L${e.key}:${e.value}')
            .join(' • '),
        subtitle: 'Counts',
        icon: Icons.stacked_bar_chart, // 📊
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.0, // adjusted for better height fit
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) => _KpiCard(item: items[i]),
    );
  }
}

class _KpiItem {
  final String title, value, subtitle;
  final IconData icon;
  _KpiItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiItem item;
  const _KpiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

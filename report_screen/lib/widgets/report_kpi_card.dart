import 'package:flutter/material.dart';

class ReportKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? deltaLabel; // "↑ 8.2% vs last week"
  final IconData? leading;
  final Widget? trailing;

  const ReportKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.deltaLabel,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (deltaLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      deltaLabel!,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: scheme.secondary),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

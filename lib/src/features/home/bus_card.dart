import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/theme.dart';

class BusCard extends StatelessWidget {
  final BusSummary bus;
  final VoidCallback? onTap;

  const BusCard({super.key, required this.bus, this.onTap});

  Color _chipColor(BuildContext context) {
    final label = bus.statusLabel.toLowerCase();
    if (label.contains('delayed') || label.contains('late') || label.contains('🟡')) {
      return ShuttleSyncTheme.amber;
    }
    return ShuttleSyncTheme.teal;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.directions_bus_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus #${bus.id} → ${bus.to}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(
                          color: _chipColor(context),
                          icon: Icons.schedule_rounded,
                          text: bus.etaLabel,
                        ),
                        _InfoChip(
                          color: cs.secondary,
                          icon: Icons.my_location_rounded,
                          text: bus.currentStop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bus.statusLabel,
                      style: TextStyle(color: Colors.black.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.black.withOpacity(0.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _InfoChip({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.85)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

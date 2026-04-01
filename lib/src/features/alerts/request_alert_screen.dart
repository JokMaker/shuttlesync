import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/bus_service.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../live_track/live_track_screen.dart';

class RequestAlertScreen extends StatefulWidget {
  const RequestAlertScreen({super.key});

  @override
  State<RequestAlertScreen> createState() => _RequestAlertScreenState();
}

class _RequestAlertScreenState extends State<RequestAlertScreen> {
  final _busService = BusService();
  StreamSubscription<List<BusData>>? _sub;
  List<BusData> _buses = const [];

  // ETA window in minutes
  int _minMinutes = 0;
  int _maxMinutes = 15;

  // Bounds (could be configurable)
  static const int kMinBound = 0;
  static const int kMaxBound = 180;

  @override
  void initState() {
    super.initState();
    _busService.startPolling();
    _sub = _busService.busStream.listen((b) {
      if (!mounted) return;
      setState(() => _buses = b);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<BusData> get _availableInWindow {
    return _buses.where((bus) => bus.etaMinutes >= _minMinutes && bus.etaMinutes <= _maxMinutes).toList(growable: false);
  }

  void _chooseBus(BusData bus) {
    // Navigate to LiveTrackScreen and tell it to focus on the chosen bus and
    // show a one-off alert that the user requested.
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LiveTrackScreen(trackedBusId: bus.id, startAlert: true),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final available = _availableInWindow;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Alert')),
      body: Stack(
        children: [
          const MeshBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick ETA window', style: AppTextStyles.outfitBold(16, Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      label: 'From (min)',
                      value: _minMinutes,
                      onChanged: (v) {
                        final newV = v.clamp(kMinBound, kMaxBound);
                        if (newV > _maxMinutes) return; // maintain min <= max
                        setState(() => _minMinutes = newV);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      label: 'To (min)',
                      value: _maxMinutes,
                      onChanged: (v) {
                        final newV = v.clamp(kMinBound, kMaxBound);
                        if (newV < _minMinutes) return;
                        setState(() => _maxMinutes = newV);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Available buses: ${available.length}', style: AppTextStyles.outfit(14, AppColors.textMuted)),
              const SizedBox(height: 12),
              Expanded(
                child: available.isEmpty
                    ? Center(child: Text('No buses found in that window', style: AppTextStyles.outfit(13, AppColors.textMuted)))
                    : ListView.separated(
                        itemCount: available.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final b = available[i];
                          return GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Bus #${b.id} — ${b.routeName}', style: AppTextStyles.outfitBold(13, Colors.white)),
                                      const SizedBox(height: 6),
                                      Text('${b.currentStop} · ETA ${b.etaLabel} · ${b.speed.toStringAsFixed(0)} km/h', style: AppTextStyles.outfit(11, AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _chooseBus(b),
                                  child: const Text('Track & Alert'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ), // Column
        ), // Padding
      ], // Stack children
    ), // Stack
  ); // Scaffold
  }

  Widget _numberField({required String label, required int value, required void Function(int) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.outfit(12, AppColors.textMuted)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => onChanged((value - 1).clamp(kMinBound, kMaxBound)),
                    ),
                    Expanded(
                      child: Center(child: Text('$value min', style: AppTextStyles.outfitBold(14, Colors.white))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => onChanged((value + 1).clamp(kMinBound, kMaxBound)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

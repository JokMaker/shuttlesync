import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme.dart';

/// Simple tap-to-drop-pin picker.
///
/// Returns a [LatLng] when user taps "Use this location".
class AddStopMapPicker extends StatefulWidget {
  final LatLng initialCenter;

  const AddStopMapPicker({
    super.key,
    this.initialCenter = const LatLng(-1.950, 30.120),
  });

  @override
  State<AddStopMapPicker> createState() => _AddStopMapPickerState();
}

class _AddStopMapPickerState extends State<AddStopMapPicker> {
  LatLng? _picked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: ShuttleSyncTheme.heroGradient),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pick stop location',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 360,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.initialCenter,
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          zoomControlsEnabled: false,
                          markers: {
                            if (_picked != null)
                              Marker(
                                markerId: const MarkerId('picked'),
                                position: _picked!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
                              ),
                          },
                          onTap: (p) => setState(() => _picked = p),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _picked == null
                        ? 'Tap the map to drop a pin.'
                        : 'Picked: ${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                    style: TextStyle(color: Colors.black.withOpacity(0.65)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _picked == null ? null : () => Navigator.pop(context, _picked),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Use this location'),
                      style: FilledButton.styleFrom(backgroundColor: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

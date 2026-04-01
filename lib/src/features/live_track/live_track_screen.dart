import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme.dart';
import '../../core/bus_service.dart';
import '../../core/widgets.dart';

class LiveTrackScreen extends StatefulWidget {
  final VoidCallback? onBack;
  /// Optional bus id to focus on when the screen opens. If null, the first
  /// available bus from the stream is used.
  final int? trackedBusId;
  /// If true, show a one-off in-app alert when the tracked bus is first found.
  final bool startAlert;

  const LiveTrackScreen({super.key, this.onBack, this.trackedBusId, this.startAlert = false});

  @override
  State<LiveTrackScreen> createState() => _LiveTrackScreenState();
}

class _LiveTrackScreenState extends State<LiveTrackScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pingController;
  final _busService = BusService();
  StreamSubscription<List<BusData>>? _sub;
  BusData? _bus1;
  bool _alertShown = false;

  static const _routePoints = [
    LatLng(-1.9478, 30.0617), // Nyabugogo
    LatLng(-1.9701, 30.0785), // Gikondo
    LatLng(-1.9500, 30.1200), // KIC Campus
  ];

  static const _mapCenter = LatLng(-1.958, 30.090);

  // Dark map style to match the app aesthetic
  static const _mapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#0a0a14"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a1a2e"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1e1e3a"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#060d13"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _busService.startPolling();
    _sub = _busService.busStream.listen((buses) {
      if (buses.isEmpty || !mounted) return;

      // If a trackedBusId was supplied, try to find that bus; otherwise use first.
      final byId = widget.trackedBusId == null
          ? null
          : buses.firstWhere((b) => b.id == widget.trackedBusId, orElse: () => buses.first);

      final chosen = byId ?? buses.first;

      // Update state + center map on chosen bus.
      setState(() => _bus1 = chosen);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_bus1!.lat, _bus1!.lng)),
      );

      // If the caller wanted an alert started when the tracked bus is first
      // available, show a one-off SnackBar to indicate the alert started.
      if (widget.startAlert && !_alertShown && widget.trackedBusId != null && _bus1!.id == widget.trackedBusId) {
        _alertShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Alert started for Bus #${_bus1!.id} — tracking on map')),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _pingController.dispose();
    _sub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    if (_bus1 == null) return {};
    return {
      Marker(
        markerId: const MarkerId('bus1'),
        position: LatLng(_bus1!.lat, _bus1!.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(200),
        infoWindow: InfoWindow(
          title: 'Bus #1',
          snippet: '${_bus1!.speed.toStringAsFixed(0)} km/h · ${_bus1!.currentStop}',
        ),
      ),
      Marker(
        markerId: const MarkerId('kic'),
        position: const LatLng(-1.9500, 30.1200),
        icon: BitmapDescriptor.defaultMarkerWithHue(160),
        infoWindow: const InfoWindow(title: 'KIC Campus', snippet: 'Destination'),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('route1'),
        points: _routePoints,
        color: AppColors.purple,
        width: 4,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bus = _bus1;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        const MeshBackground(
          orb1Color: Color(0x997B5BFF),
          orb2Color: Color(0x4400C896),
          orb1Pos: Alignment(0.5, -1.0),
          orb2Pos: Alignment(-0.5, 1.0),
        ),
        Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _mapCenter,
                      zoom: 12.5,
                    ),
                    onMapCreated: (c) {
                      _mapController = c;
                      c.setMapStyle(_mapStyle);
                    },
                    markers: _buildMarkers(),
                    polylines: _buildPolylines(),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.bg.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPad + 12,
                    left: 56,
                    right: 12,
                    child: GlassCard(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xB3080810),
                          Color(0x99080810),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bus #1 — Live', style: AppTextStyles.outfitBold(13, Colors.white)),
                              const SizedBox(height: 2),
                              Text(
                                bus != null
                                    ? '${bus.currentStop} · ${bus.speed.toStringAsFixed(0)} km/h'
                                    : 'Locating...',
                                style: AppTextStyles.outfit(10, AppColors.textMuted),
                              ),
                            ],
                          ),
                          GradientText(
                            bus != null
                                ? '${bus.etaMinutes}:${bus.etaSeconds.toString().padLeft(2, '0')}'
                                : '--:--',
                            style: AppTextStyles.outfitBlack(24, Colors.white),
                            gradient: AppGradients.brand,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                  ),
                  Positioned(
                    top: topPad + 12,
                    left: 12,
                    child: GlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: widget.onBack ?? () => Navigator.maybePop(context),
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    if (bus != null)
                      Row(
                        children: [
                          Expanded(
                            child: _fallbackStatTile(
                              value: '${bus.etaMinutes}:${bus.etaSeconds.toString().padLeft(2, '0')}',
                              label: 'ETA',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _fallbackStatTile(
                              value: '${bus.speed.toStringAsFixed(0)}',
                              label: 'km/h',
                              valueColor: AppColors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _fallbackStatTile(
                              value: bus.isOnTime ? 'On time' : 'Late',
                              label: 'Status',
                              valueColor: bus.isOnTime ? AppColors.teal : AppColors.statusDelayed,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 10),
                    GlassCard(
                      gradient: const LinearGradient(
                        colors: [Color(0x337B5BFF), Color(0x2600C896)],
                      ),
                      borderColor: AppColors.glassBorderStrong,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fadeOut(duration: 800.ms),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arriving in 2 min at your stop',
                                  style: AppTextStyles.outfitBold(13, Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Nyabugogo Terminal · Bus #1',
                                  style: AppTextStyles.outfit(10, AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 10),
                    if (bus != null)
                      _fallbackRouteProgressCard(progress: bus.routeProgress)
                          .animate()
                          .fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackStatTile({
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.outfit(10, AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.outfitBlack(16, valueColor ?? Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _fallbackRouteProgressCard({required double progress}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journey progress', style: AppTextStyles.outfit(12, AppColors.textSecondary)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}

// The legacy LiveTrackScreen implementation previously had additional widgets
// (_MapCard/_DetailsCard/_EtaGraphCard) using BusApi + fl_chart.
// Those are intentionally removed in this new version.

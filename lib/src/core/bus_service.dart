import 'dart:async';
import 'dart:math';

import 'app_config.dart';
import 'bus_api.dart';

class BusData {
  final int id;
  final String route;
  final String via;
  final String status; // 'on_time' | 'delayed'
  final int etaMinutes;
  final int etaSeconds;
  final double speed;
  final String currentStop;
  final double routeProgress; // 0.0 to 1.0
  final double lat;
  final double lng;

  const BusData({
    required this.id,
    required this.route,
    required this.via,
    required this.status,
    required this.etaMinutes,
    required this.etaSeconds,
    required this.speed,
    required this.currentStop,
    required this.routeProgress,
    required this.lat,
    required this.lng,
  });

  bool get isOnTime => status == 'on_time';

  // Compatibility aliases for the existing UI components.
  String get routeName => route;
  String get destination => via;
  String get etaLabel => '${etaMinutes}m';
  bool get isLive => true;
}

class BusService {
  static final BusService _instance = BusService._internal();
  factory BusService() => _instance;
  BusService._internal();

  final _controller = StreamController<List<BusData>>.broadcast();
  Timer? _timer;
  final _rng = Random();

  /// If [AppConfig.apiBaseUrl] is empty, BusApi falls back to demo data.
  late final BusApi _api = BusApi(baseUrl: AppConfig.apiBaseUrl);

  Stream<List<BusData>> get busStream => _controller.stream;

  bool get _shouldPoll {
    // In widget tests, a periodic timer can cause `timersPending` failures.
    // We keep emitting once so the UI still has data, but avoid scheduling
    // the repeating timer.
    final inTest = const bool.fromEnvironment('FLUTTER_TEST');
    return !inTest;
  }

  void startPolling() {
    _emit();
    _timer?.cancel();
    if (_shouldPoll) {
      _timer = Timer.periodic(const Duration(seconds: 15), (_) => _emit());
    }
  }

  void stopPolling() {
    _timer?.cancel();
  }

  void _emit() {
    // Poll the backend. If it fails, Fall back to demo-like values.
    () async {
      final summaries = await _api.fetchBusSummaries();

      // Map BusSummary -> BusData (and enrich with demo-ish values that the UI
      // expects, until the FastAPI payload includes them).
      final buses = summaries.map((s) {
        final onTime = s.statusLabel.toLowerCase().contains('on time') ||
            s.statusLabel.toLowerCase().contains('on_time') ||
            s.statusLabel.toLowerCase().contains('on-time');

        final etaMinutes = _parseEtaMinutes(s.etaLabel) ?? (5 + _rng.nextInt(15));

        // If the API doesn't provide coordinates yet, we jitter around a known
        // Kigali area so the map still animates.
        final baseLat = -1.9478 + (_rng.nextDouble() - 0.5) * 0.01;
        final baseLng = 30.1152 + (_rng.nextDouble() - 0.5) * 0.02;

        return BusData(
          id: s.id,
          route: s.to,
          via: s.currentStop,
          status: onTime ? 'on_time' : 'delayed',
          etaMinutes: etaMinutes,
          etaSeconds: _rng.nextInt(59),
          speed: onTime ? 22.0 + _rng.nextInt(10) : 10.0 + _rng.nextInt(8),
          currentStop: s.currentStop,
          routeProgress: 0.2 + _rng.nextDouble() * 0.7,
          lat: baseLat,
          lng: baseLng,
        );
      }).toList(growable: false);

      _controller.add(buses);
    }();
  }

  int? _parseEtaMinutes(String etaLabel) {
    // Accept labels like: "8min 32s", "8 min", "8m", "Delayed 5min".
    final m = RegExp(r'(\d+)\s*(?:min|m)\b', caseSensitive: false)
        .firstMatch(etaLabel);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }
}

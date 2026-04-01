import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Small API abstraction.
///
/// Contract:
/// - If [baseUrl] is null/empty or network fails, we fall back to demo data.
/// - Designed for your FastAPI: GET /api/buses.
class BusApi {
  final String? baseUrl;
  final http.Client _client;

  BusApi({this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Future<List<BusSummary>> fetchBusSummaries() async {
    final url = baseUrl;
    if (url == null || url.isEmpty) {
      return _demoSummaries();
    }

    try {
      final res = await _client.get(Uri.parse('$url/api/buses'));
      if (res.statusCode != 200) return _demoSummaries();

      final decoded = jsonDecode(res.body);

      // Accept either {buses:[...]} or a raw list.
      final list = (decoded is Map && decoded['buses'] is List)
          ? decoded['buses'] as List
          : (decoded is List)
              ? decoded
              : <dynamic>[];

      if (list.isEmpty) return _demoSummaries();

      return list
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => BusSummary(
              id: (m['id'] as num?)?.toInt() ?? 0,
              to: (m['to'] as String?) ?? 'KIC Campus',
              statusLabel: (m['status'] as String?) ?? '🟢 On Time',
              etaLabel: (m['eta'] as String?) ?? '8min 32s',
              currentStop: (m['current'] as String?) ?? 'Nyabugogo',
            ),
          )
          .toList();
    } catch (_) {
      return _demoSummaries();
    }
  }

  Future<BusLiveDetails> fetchBusLiveDetails(int busId) async {
    // In 48h mode we use demo payload.
    // You can wire this to /api/buses/{id} later.
    final summaries = await fetchBusSummaries();
    final summary = summaries.firstWhere(
      (b) => b.id == busId,
      orElse: () => const BusSummary(
        id: 1,
        to: 'KIC Campus',
        statusLabel: '🟢 On Time',
        etaLabel: '8min 32s',
        currentStop: 'Nyabugogo Market',
      ),
    );

    return BusLiveDetails(
      summary: summary,
      lat: -1.948,
      lng: 30.115,
      speedKmh: 28,
      polyline: const [
        [-1.948, 30.115],
        [-1.9495, 30.117],
        [-1.95, 30.12],
      ],
    );
  }

  List<BusSummary> _demoSummaries() {
    return const [
      BusSummary(
        id: 1,
        to: 'KIC Campus',
        statusLabel: '🟢 On Time',
        etaLabel: '8min 32s',
        currentStop: 'Nyabugogo',
      ),
      BusSummary(
        id: 2,
        to: 'KIC Campus',
        statusLabel: '🟡 Delayed 5min',
        etaLabel: 'Delayed 5min',
        currentStop: 'Remera',
      ),
    ];
  }
}

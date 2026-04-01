class BusSummary {
  final int id;
  final String to;
  final String statusLabel;
  final String etaLabel;
  final String currentStop;

  const BusSummary({
    required this.id,
    required this.to,
    required this.statusLabel,
    required this.etaLabel,
    required this.currentStop,
  });
}

class BusLiveDetails {
  final BusSummary summary;
  final double lat;
  final double lng;
  final double speedKmh;
  final List<List<double>> polyline;

  const BusLiveDetails({
    required this.summary,
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.polyline,
  });
}

class MyStop {
  final String name;
  final bool isHome;
  final double? lat;
  final double? lng;

  const MyStop({
    required this.name,
    this.isHome = false,
    this.lat,
    this.lng,
  });

  bool get hasLocation => lat != null && lng != null;
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/bus_service.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../alerts/request_alert_screen.dart' as alerts;
import '../live_track/live_track_screen.dart';
import '../my_stops/my_stops_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _busService = BusService();

  @override
  void initState() {
    super.initState();
    _busService.startPolling();
  }

  @override
  void dispose() {
    _busService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return const LiveTrackScreen();
      case 2:
        return const MyStopsScreen();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Stack(
      children: [
        const MeshBackground(),
        Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<BusData>>(
                stream: _busService.busStream,
                builder: (context, snapshot) {
                  final buses = snapshot.data ?? const <BusData>[];
                  return _buildContent(buses);
                },
              ),
            ),
            AppBottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppWordmark(size: 22),
              SizedBox(height: 6),
              LiveBadge(),
            ],
          ),
          GlassIconButton(
            icon: Icons.notifications_active_outlined,
            size: 38,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const alerts.RequestAlertScreen()),
              );
            },
          ),
          GlassIconButton(
            icon: Icons.settings_outlined,
            size: 38,
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Settings', style: AppTextStyles.outfitBlack(18, Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            'This build is running in demo mode.\n\nNext: we can wire BusService to the existing BusApi so this screen reflects live server data.',
                            style: AppTextStyles.outfit(12, AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close', style: AppTextStyles.outfit(12, AppColors.teal)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<BusData> buses) {
    final bus1 = buses.isNotEmpty ? buses[0] : null;
    final bus2 = buses.length > 1 ? buses[1] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          if (bus1 == null)
            const _LoadingCard()
          else
            _fallbackHero(bus1)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.08, end: 0, duration: 400.ms),

          const SizedBox(height: 12),

          if (bus1 != null)
            _fallbackRouteProgress(progress: bus1.routeProgress)
                .animate()
                .fadeIn(delay: 80.ms, duration: 400.ms),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _fallbackBento(
                  icon: Icons.my_location_rounded,
                  value: 'Live',
                  label: 'Track map',
                  accent: true,
                  onTap: () => setState(() => _navIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fallbackBento(
                  icon: Icons.place_rounded,
                  value: '3',
                  label: 'My stops',
                  onTap: () => setState(() => _navIndex = 2),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: 12),

          if (bus2 != null)
            _fallbackCompact(bus2)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Temporary fallbacks:
  // Your widget kit references BusHeroCard / BusCompactCard / RouteProgressCard /
  // BentoTile. Once you drop in those widgets, we can swap these out.

  Widget _fallbackHero(BusData bus) {
    return GlassCard(
      gradient: AppGradients.heroBg,
      child: InkWell(
        onTap: () => setState(() => _navIndex = 1),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus.routeName, style: AppTextStyles.outfitBlack(18, Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    'To ${bus.destination}',
                    style: AppTextStyles.outfit(12, AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('ETA', style: AppTextStyles.outfit(11, AppColors.textMuted)),
                      const SizedBox(width: 6),
                      Text(bus.etaLabel, style: AppTextStyles.outfitBlack(20, AppColors.teal)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppGradients.brandDiagonal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.directions_bus_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackRouteProgress({required double progress}) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route progress', style: AppTextStyles.outfit(12, AppColors.textSecondary)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBento({
    required IconData icon,
    required String value,
    required String label,
    bool accent = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        gradient: accent ? AppGradients.brand : null,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTextStyles.outfitBlack(16, Colors.white)),
                  const SizedBox(height: 2),
                  Text(label, style: AppTextStyles.outfit(11, AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _fallbackCompact(BusData bus) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.directions_bus_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.routeName,
                  style: AppTextStyles.outfit(13, Colors.white, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('ETA ${bus.etaLabel}', style: AppTextStyles.outfit(11, AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            bus.isLive ? 'Live' : 'Offline',
            style: AppTextStyles.outfit(11, AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.teal,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

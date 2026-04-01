import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';

class _Stop {
  final int number;
  final String name;
  final String tag;
  final bool isHome;
  const _Stop({
    required this.number,
    required this.name,
    required this.tag,
    this.isHome = false,
  });
}

class MyStopsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MyStopsScreen({super.key, this.onBack});

  @override
  State<MyStopsScreen> createState() => _MyStopsScreenState();
}

class _MyStopsScreenState extends State<MyStopsScreen> {
  bool _alertsOn = true;
  bool _autoDetect = true;

  final _stops = const [
    _Stop(number: 1, name: 'Nyabugogo Terminal', tag: 'Home stop', isHome: true),
    _Stop(number: 2, name: 'Gikondo Junction', tag: 'Waypoint'),
    _Stop(number: 3, name: 'KIC Campus', tag: 'Drop-off'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MeshBackground(
          orb1Color: Color(0x5900C896),
          orb2Color: Color(0x667B5BFF),
          orb1Pos: Alignment(-0.6, -0.7),
          orb2Pos: Alignment(0.8, 0.8),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: _stops.asMap().entries.map((e) {
                            final stop = e.value;
                            final isLast = e.key == _stops.length - 1;
                            return Column(
                              children: [
                                _buildStopRow(stop),
                                if (!isLast)
                                  Container(
                                    height: 0.5,
                                    margin: const EdgeInsets.only(left: 58),
                                    color: AppColors.glassBorder,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                      const SizedBox(height: 12),

                      GlassCard(
                        child: Column(
                          children: [
                            _buildToggle(
                              label: 'Stop alerts',
                              sub: 'Notify 2 min before arrival',
                              value: _alertsOn,
                              onChanged: (v) => setState(() => _alertsOn = v),
                            ),
                            Container(
                              height: 0.5,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              color: AppColors.glassBorder,
                            ),
                            _buildToggle(
                              label: 'Auto-detect location',
                              sub: 'Find nearest stop automatically',
                              value: _autoDetect,
                              onChanged: (v) => setState(() => _autoDetect = v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => _showAddSheet(context),
                        child: GlassCard(
                          gradient: const LinearGradient(
                            colors: [Color(0x4D7B5BFF), Color(0x3300C896)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: AppColors.glassBorderStrong,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_rounded, color: AppColors.teal, size: 18),
                              const SizedBox(width: 8),
                              Text('Add Stop', style: AppTextStyles.outfitBold(13, Colors.white)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 12),

                      Text(
                        'Route synced across devices',
                        style: AppTextStyles.outfit(10, AppColors.textHint),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Route',
                style: AppTextStyles.outfitBlack(26, Colors.white).copyWith(letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Text(
                '${_stops.length} stops saved · synced',
                style: AppTextStyles.outfit(11, AppColors.textMuted),
              ),
            ],
          ),
          if (widget.onBack != null)
            GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: widget.onBack,
              size: 38,
            ),
        ],
      ),
    );
  }

  Widget _buildStopRow(_Stop stop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: stop.isHome ? AppGradients.brandDiagonal : null,
              color: stop.isHome ? null : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${stop.number}',
                style: AppTextStyles.outfitBlack(
                  13,
                  stop.isHome ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: AppTextStyles.outfitSemiBold(13, AppColors.textPrimary)),
                Text(stop.tag, style: AppTextStyles.outfit(10, AppColors.textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.outfitSemiBold(13, AppColors.textPrimary)),
            Text(sub, style: AppTextStyles.outfit(10, AppColors.textMuted)),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.teal,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.glassWhite,
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add a Stop',
              style: AppTextStyles.outfitBlack(22, Colors.white).copyWith(letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            TextField(
              style: AppTextStyles.outfit(14, Colors.white),
              decoration: InputDecoration(
                hintText: 'Search stop name...',
                hintStyle: AppTextStyles.outfit(14, AppColors.textMuted),
                filled: true,
                fillColor: AppColors.glassWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
                ),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Confirm Stop', style: AppTextStyles.outfitBold(13, Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../live_track/live_track_screen.dart';
import '../my_stops/my_stops_screen.dart';
import '../../core/widgets.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const LiveTrackScreen(),
      const MyStopsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const MeshBackground(),
          SafeArea(
            child: pages[_index],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

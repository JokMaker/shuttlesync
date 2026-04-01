import 'package:flutter/material.dart';

import '../core/bus_api.dart';
import '../core/theme.dart';
import '../features/splash/splash_screen.dart';

class ShuttleSyncApp extends StatelessWidget {
  const ShuttleSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShuttleSyncScope(
      busApi: BusApi(
        // 48-hour build default: demo mode.
        // Set to e.g. 'http://10.0.2.2:8000' for Android emulator.
        baseUrl: const String.fromEnvironment('SHUTTLESYNC_API_BASE_URL'),
      ),
      child: MaterialApp(
        title: 'ShuttleSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}

class ShuttleSyncScope extends InheritedWidget {
  final BusApi busApi;

  const ShuttleSyncScope({
    super.key,
    required this.busApi,
    required super.child,
  });

  static ShuttleSyncScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShuttleSyncScope>();
    assert(scope != null, 'ShuttleSyncScope not found.');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShuttleSyncScope oldWidget) => busApi != oldWidget.busApi;
}

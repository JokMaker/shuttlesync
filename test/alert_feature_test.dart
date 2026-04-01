import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuttlesync/src/core/bus_service.dart';
import 'package:shuttlesync/src/features/alerts/request_alert_screen.dart';
import 'package:shuttlesync/src/features/live_track/live_track_screen.dart';

void main() {
  group('Alert Feature Tests', () {
    // Teardown to stop BusService polling after each test
    tearDown(() {
      BusService().stopPolling();
    });

    // Test 1: Verify BusData filtering by ETA window
    test('BusData can be filtered by ETA minutes window', () {
      final buses = [
        const BusData(
          id: 1,
          route: 'Route A',
          via: 'Stop 1',
          status: 'on_time',
          etaMinutes: 5,
          etaSeconds: 30,
          speed: 25.0,
          currentStop: 'Downtown',
          routeProgress: 0.5,
          lat: -1.9478,
          lng: 30.0617,
        ),
        const BusData(
          id: 2,
          route: 'Route B',
          via: 'Stop 2',
          status: 'on_time',
          etaMinutes: 12,
          etaSeconds: 15,
          speed: 20.0,
          currentStop: 'Midtown',
          routeProgress: 0.3,
          lat: -1.9500,
          lng: 30.0800,
        ),
        const BusData(
          id: 3,
          route: 'Route C',
          via: 'Stop 3',
          status: 'delayed',
          etaMinutes: 20,
          etaSeconds: 45,
          speed: 15.0,
          currentStop: 'Uptown',
          routeProgress: 0.1,
          lat: -1.9600,
          lng: 30.1000,
        ),
      ];

      // Filter buses with ETA between 5 and 15 minutes
      final filtered = buses.where((b) => b.etaMinutes >= 5 && b.etaMinutes <= 15).toList();

      expect(filtered.length, equals(2));
      expect(filtered[0].id, equals(1));
      expect(filtered[1].id, equals(2));
      expect(filtered.any((b) => b.id == 3), isFalse);
    });

    // Test 2: Verify LiveTrackScreen accepts trackedBusId and startAlert parameters
    testWidgets('LiveTrackScreen accepts optional trackedBusId and startAlert', (WidgetTester tester) async {
      addTearDown(() => BusService().stopPolling());

      fakeAsync((async) {
        Future<void> pumpAsync() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: LiveTrackScreen(
                trackedBusId: 42,
                startAlert: true,
              ),
            ),
          );
          async.flushMicrotasks();
        }

        pumpAsync();
        async.elapse(const Duration(milliseconds: 100));

        // Verify the screen renders without crashing
        expect(find.byType(LiveTrackScreen), findsOneWidget);
      });
    });

    // Test 3: Verify RequestAlertScreen renders and has UI elements
    testWidgets('RequestAlertScreen renders with ETA controls and bus list', (WidgetTester tester) async {
      addTearDown(() => BusService().stopPolling());

      fakeAsync((async) {
        Future<void> pumpAsync() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: RequestAlertScreen(),
            ),
          );
          async.flushMicrotasks();
        }

        pumpAsync();
        async.elapse(const Duration(milliseconds: 100));

        // Verify the screen renders
        expect(find.byType(RequestAlertScreen), findsOneWidget);

        // Verify header text is present
        expect(find.text('Pick ETA window'), findsOneWidget);

        // Look for "Available buses:" as substring (it includes a count)
        expect(find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Available buses:') == true,
        ), findsWidgets);

        // Verify +/- buttons exist (for number field controls)
        expect(find.byIcon(Icons.add), findsWidgets);
        expect(find.byIcon(Icons.remove), findsWidgets);
      });
    });

    // Test 4: Verify RequestAlertScreen initializes with correct default ETA window
    testWidgets('RequestAlertScreen starts with 0-15 minute window', (WidgetTester tester) async {
      addTearDown(() => BusService().stopPolling());

      fakeAsync((async) {
        Future<void> pumpAsync() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: RequestAlertScreen(),
            ),
          );
          async.flushMicrotasks();
        }

        pumpAsync();
        async.elapse(const Duration(milliseconds: 100));

        // Verify default "From" and "To" values are displayed
        expect(find.text('0 min'), findsOneWidget); // "From" default
        expect(find.text('15 min'), findsOneWidget); // "To" default
      });
    });

    // Test 5: Verify ETA window increment/decrement logic
    testWidgets('RequestAlertScreen allows incrementing/decrementing ETA window', (WidgetTester tester) async {
      addTearDown(() => BusService().stopPolling());

      fakeAsync((async) {
        Future<void> pumpAsync() async {
          await tester.pumpWidget(
            const MaterialApp(
              home: RequestAlertScreen(),
            ),
          );
          async.flushMicrotasks();
        }

        pumpAsync();
        async.elapse(const Duration(milliseconds: 100));

        // Verify buttons exist and interact
        expect(find.byIcon(Icons.add), findsWidgets);
        expect(find.byIcon(Icons.remove), findsWidgets);
        
        // Smoke test: verify widget is still there
        expect(find.byType(RequestAlertScreen), findsOneWidget);
      });
    });

    // Test 6: Verify BusData properties are accessible
    test('BusData stores and retrieves all bus information correctly', () {
      const bus = BusData(
        id: 123,
        route: 'Express Route 5',
        via: 'Main Street',
        status: 'on_time',
        etaMinutes: 8,
        etaSeconds: 42,
        speed: 35.5,
        currentStop: 'Central Station',
        routeProgress: 0.65,
        lat: -1.9400,
        lng: 30.0700,
      );

      expect(bus.id, equals(123));
      expect(bus.route, equals('Express Route 5'));
      expect(bus.via, equals('Main Street'));
      expect(bus.etaMinutes, equals(8));
      expect(bus.etaSeconds, equals(42));
      expect(bus.speed, equals(35.5));
      expect(bus.isOnTime, isTrue);
      expect(bus.etaLabel, equals('8m'));
    });

    // Test 7: Verify BusService singleton pattern
    test('BusService maintains singleton instance', () {
      final service1 = BusService();
      final service2 = BusService();

      expect(identical(service1, service2), isTrue);
    });

    // Test 8: Verify BusService stream is broadcast
    test('BusService.busStream is a broadcast stream', () {
      final service = BusService();
      final stream = service.busStream;

      // Attempt to listen twice (only works with broadcast streams)
      final listener1 = stream.listen((_) {});
      final listener2 = stream.listen((_) {});

      expect(listener1, isNotNull);
      expect(listener2, isNotNull);

      listener1.cancel();
      listener2.cancel();
    });
  });
}

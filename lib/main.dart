import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app/shuttlesync_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar — text white (matches dark bg)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080810),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ShuttleSyncApp());
}

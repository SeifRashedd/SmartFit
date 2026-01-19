import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/gender_view.dart';

void main() {
  developer.log('[Main] Starting Smart Fit application...', name: 'Main');

  WidgetsFlutterBinding.ensureInitialized();
  developer.log('[WidgetsFlutterBinding] Initialized', name: 'Main');

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    developer.log('[Main] Preferred orientations set', name: 'Main');
  });

  developer.log('[Main] Running app...', name: 'Main');
  runApp(const SmartFitApp());
}

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('[SmartFitApp] Building app widget...', name: 'SmartFitApp');

    return MaterialApp(
      title: 'Smart Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const GenderView(),
    );
  }
}

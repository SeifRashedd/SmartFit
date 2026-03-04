import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/features/app_settings/logic/app_settings_cubit.dart';
import 'package:smartfit/features/app_settings/views/splash_screen.dart';
import 'package:smartfit/features/body_dect/views/detect_body_view.dart';
import 'package:smartfit/features/face_dect/views/detect_face_view.dart';

void main() {
  developer.log('[Main] Starting Smart Fit application...', name: 'Main');

  WidgetsFlutterBinding.ensureInitialized();
  developer.log('[WidgetsFlutterBinding] Initialized', name: 'Main');

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
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

    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AppSettingCubit())],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF5F7FA)),
        title: 'Smart Fit',
        debugShowCheckedModeBanner: false,
        // home: const GenderView(),
        home: const DetectBodyView(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartfit/features/app_settings/logic/app_settings_cubit.dart';
import 'package:smartfit/features/app_settings/views/on_bording_view.dart';
import 'package:smartfit/features/body_dect/views/detect_body_view.dart';
import 'package:smartfit/features/face_dect/views/detect_face_view.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://kudugwnmzsuiwhzqjuzo.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1ZHVnd25tenN1aXdoenFqdXpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NTc2MzYsImV4cCI6MjA4OTIzMzYzNn0.vyiwlOe4kVEzp70LLzUAtRjgN8TohSDSWSPdWRcpTYo';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final userCubit = UserCubit();
  await userCubit.initData();

  runApp(SmartFitApp(userCubit: userCubit));
}

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key, required this.userCubit});

  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppSettingCubit()),
        BlocProvider.value(value: userCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF5F7FA)),
        title: 'Smart Fit',
        debugShowCheckedModeBanner: false,
        home: _resolveInitialView(userCubit),
      ),
    );
  }

  Widget _resolveInitialView(UserCubit userCubit) {
    if (!userCubit.hasSeenOnboarding) {
      return const OnBoardingView();
    }

    final hasGender = (userCubit.gender ?? '').isNotEmpty;
    final hasBody = (userCubit.topSize ?? '').isNotEmpty &&
        (userCubit.bottomSize ?? '').isNotEmpty;

    if (hasGender && hasBody) {
      return const HomeView();
    }
    if (hasGender) {
      return const DetectBodyView();
    }
    return const DetectFaceView();
  }
}

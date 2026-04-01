import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/features/auth/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartfit/features/app_settings/logic/app_settings_cubit.dart';
import 'package:smartfit/features/app_settings/views/splash_screen.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://kudugwnmzsuiwhzqjuzo.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1ZHVnd25tenN1aXdoenFqdXpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NTc2MzYsImV4cCI6MjA4OTIzMzYzNn0.vyiwlOe4kVEzp70LLzUAtRjgN8TohSDSWSPdWRcpTYo';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final userCubit = UserCubit();
  await userCubit.initData();

  runApp(SmartFitApp(userCubit: userCubit));
}

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key, this.userCubit});

  final UserCubit? userCubit;

  @override
  Widget build(BuildContext context) {
    final appUserCubit = userCubit ?? UserCubit();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppSettingCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider.value(value: appUserCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF5F7FA)),
        title: 'Smart Fit',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

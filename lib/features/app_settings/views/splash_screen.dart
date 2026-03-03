import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 1));


    if (!mounted) return;

    // if (isLogin) {
    //   await initData(context);
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomBottomNavigationBar()));
    // } else {
    //   await context.read<AppSettingCubit>().getCountries();
    //   if (!mounted) return;
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnbordingView()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
            stops: [0.6, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E90FF), Color(0xFFFF69B4)],
          ),
        ),
        child: Center(child: Image.asset('assets/images/Smart_fit_logo.png', fit: BoxFit.fill, color: Colors.white)),
      ),
    );
  }
}

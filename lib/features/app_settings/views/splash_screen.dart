import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/features/app_settings/views/on_bording_view.dart';

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

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnBoardingView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: Center(child: _SplashContent())),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 240,
          height: 240,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.20), blurRadius: 22)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22 - 8),
            child: Image.asset('assets/images/Smart_fit_logo.png', fit: BoxFit.fill),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class OnBoardingTopBar extends StatelessWidget {
  const OnBoardingTopBar({super.key, required this.index, required this.onSkip});

  final int index;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final showSkip = index < 2;

    return Align(
      alignment: Alignment.centerRight,
      child: showSkip
          ? TextButton(
              onPressed: onSkip,
              child: Text('Skip', style: AppFonts.montserrat14Regular64748B),
            )
          : const SizedBox.shrink(),
    );
  }
}


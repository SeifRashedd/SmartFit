import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.12)),
            child: Image.asset('assets/images/Smart_fit_logo.png'),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppFonts.montserrat30BoldBlack, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: AppFonts.montserrat14Regular64748B, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

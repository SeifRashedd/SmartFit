import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class InfoCardBodyDetect extends StatelessWidget {
  final String assetPath;
  final String title;

  const InfoCardBodyDetect({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 22,
              height: 22,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.montserrat13RegularBlack.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

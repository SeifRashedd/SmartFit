import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.dotsCount,
    required this.dotsActive,
    required this.dotsActiveColor,
  });

  final String imagePath;
  final String title;
  final String description;
  final int dotsCount;
  final int dotsActive;
  final Color dotsActiveColor;

  @override
  Widget build(BuildContext context) {
    final textDark = const Color(0xFF0F172A);
    final primary = AppColors.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        OnBoardingDots(
          count: dotsCount,
          active: dotsActive,
          activeColor: dotsActiveColor,
          inactiveColor: const Color(0xFFCBD5E1),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: OnBoardingHighlightedTitle(
            title: title,
            primary: primary,
            textColor: textDark,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: AppFonts.montserrat13RegularBlack,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class OnBoardingHighlightedTitle extends StatelessWidget {
  const OnBoardingHighlightedTitle({
    super.key,
    required this.title,
    required this.primary,
    required this.textColor,
  });

  final String title;
  final Color primary;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length <= 1) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: AppFonts.montserrat24MediumWhite.copyWith(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    final last = words.removeLast();
    final prefix = '${words.join(' ')} ';

    return Text.rich(
      TextSpan(
        text: prefix,
        style: AppFonts.montserrat30BoldBlack,
        children: [
          TextSpan(
            text: last,
            style: AppFonts.montserrat30BoldPrimary,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class OnBoardingDots extends StatelessWidget {
  const OnBoardingDots({
    super.key,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int active;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 22 : 6,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}


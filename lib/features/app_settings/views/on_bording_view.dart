import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/app_settings/logic/app_settings_cubit.dart';
import 'package:smartfit/features/body_dect/views/body_detect_view.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OnBoardingScaffold();
  }
}

class _OnBoardingScaffold extends StatefulWidget {
  const _OnBoardingScaffold();

  @override
  State<_OnBoardingScaffold> createState() => _OnBoardingScaffoldState();
}

class _OnBoardingScaffoldState extends State<_OnBoardingScaffold> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppSettingCubit>();
    _controller = PageController(initialPage: cubit.selectedOnBoardingScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BodyDetectView()));
  }

  void _primaryCtaPressed() {
    final cubit = context.read<AppSettingCubit>();
    final isLast = cubit.selectedOnBoardingScreen >= cubit.onBoardingScreens.length - 1;
    if (isLast) {
      _skip();
      return;
    }
    cubit.changeOnboardingScreen();
    _controller.animateToPage(
      cubit.selectedOnBoardingScreen,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return BlocBuilder<AppSettingCubit, AppSettingsState>(
      buildWhen: (_, next) => next is OnBoardingState || next is AppSettingInitial,
      builder: (context, _) {
        final cubit = context.read<AppSettingCubit>();
        final pages = cubit.onBoardingScreens;
        final index = cubit.selectedOnBoardingScreen;
        final isLast = index >= pages.length - 1;

        final primaryLabel = switch (index) {
          0 => 'Find My Fit',
          1 => 'Next',
          _ => 'Get Started',
        };

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: AppConstants.appPadding,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: _TopBar(index: index, onSkip: _skip),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (i) => context.read<AppSettingCubit>().setOnboardingScreen(i),
                      itemBuilder: (context, i) {
                        final data = pages[i];
                        return _OnBoardingPage(
                          imagePath: (data['img'] ?? '').toString(),
                          title: (data['title'] ?? '').toString(),
                          description: (data['description'] ?? '').toString(),
                          dotsCount: pages.length,
                          dotsActive: index,
                          dotsActiveColor: primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _primaryCtaPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(primaryLabel, style: AppFonts.montserrat16MediumWhite),
                          if (!isLast) ...[
                            const SizedBox(width: 10),
                            if (index == 0)
                              SvgPicture.asset(
                                'assets/images/checkroom.svg',
                                width: 15,
                                height: 15,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              )
                            else
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.onSkip});

  final int index;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    // Show "Skip" only on first two onboarding screens.
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

class _OnBoardingPage extends StatelessWidget {
  const _OnBoardingPage({
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
    final primary = const Color(0xFF15A7FF);

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
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              ),
            ),
          ),
        ),
        _Dots(
          count: dotsCount,
          active: dotsActive,
          activeColor: dotsActiveColor,
          inactiveColor: const Color(0xFFCBD5E1),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _HighlightedTitle(title: title, primary: primary, textColor: textDark),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(description, textAlign: TextAlign.center, style: AppFonts.montserrat13RegularBlack),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _HighlightedTitle extends StatelessWidget {
  const _HighlightedTitle({required this.title, required this.primary, required this.textColor});

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
        style: AppFonts.montserrat24MediumWhite.copyWith(color: textColor, fontSize: 24, fontWeight: FontWeight.w800),
      );
    }

    final last = words.removeLast();
    final prefix = '${words.join(' ')} ';

    return Text.rich(
      TextSpan(
        text: prefix,
        style: AppFonts.montserrat30BoldBlack,
        children: [TextSpan(text: last, style: AppFonts.montserrat30BoldPrimary)],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active, required this.activeColor, required this.inactiveColor});

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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/app_settings/logic/app_settings_cubit.dart';
import 'package:smartfit/features/app_settings/views/widgets/onboarding_page.dart';
import 'package:smartfit/features/app_settings/views/widgets/onboarding_top_bar.dart';
import 'package:smartfit/features/body_dect/views/body_detect_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
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
                    child: OnBoardingTopBar(index: index, onSkip: _skip),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (i) => context.read<AppSettingCubit>().setOnboardingScreen(i),
                      itemBuilder: (context, i) {
                        final data = pages[i];
                        return OnBoardingPage(
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/body_dect/widget/info_card_body_detect.dart';

class DetectBodyView extends StatelessWidget {
  const DetectBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Smart Fit', style: AppFonts.montserrat18BoldBlack),
              SizedBox(height: 20),
              Text(
                "Let's map your body",
                style: AppFonts.montserrat30BoldBlack,
              ),
              SizedBox(height: 15),
              Text(
                'Our AI analyzes your shape in seconds for personalized recommendations.',
                style: AppFonts.montserrat14Regular64748B,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '100% Private & Processed Locally',
                      style: AppFonts.montserrat13BoldPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 350,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/detect_body_image.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  InfoCardBodyDetect(
                    assetPath: 'assets/images/hanger.png',
                    title: 'Tight-fitting\nclothing',
                  ),
                  InfoCardBodyDetect(
                    assetPath: 'assets/images/sun.png',
                    title: 'Good\nlighting',
                  ),
                  InfoCardBodyDetect(
                    assetPath: 'assets/images/person_stand.png',
                    title: 'Stand\nfull body',
                  ),
                ],
              ),
              Spacer(),
              CustomButton(
                onPressed: () {},
                text: 'Start Body Scan',
                showIcon: true,
                icon: const Icon(Icons.man_rounded, size: 18),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

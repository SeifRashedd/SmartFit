import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class DetectFaceView extends StatelessWidget {
  const DetectFaceView({super.key});

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
              Text("Let's map your face", style: AppFonts.montserrat30BoldBlack),
              SizedBox(height: 15),
              Text(
                'Our AI analyzes your facial features for personalized accessory and grooming recommendations.',
                style: AppFonts.montserrat14Regular64748B,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFE6F7FF), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('100% Private & Processed Locally', style: AppFonts.montserrat13BoldPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                margin: EdgeInsets.all(12),
                child: Image.asset('assets/images/detect_face_image.png', fit: BoxFit.fill),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

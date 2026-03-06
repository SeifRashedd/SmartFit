import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/body_dect/model/body_detect_model.dart';
import 'package:smartfit/features/body_dect/views/body_detect_guided_camera_view.dart';
import 'package:smartfit/features/body_dect/widget/info_card_body_detect.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';

class DetectBodyView extends StatefulWidget {
  const DetectBodyView({super.key});

  @override
  State<DetectBodyView> createState() => _DetectBodyViewState();
}

class _DetectBodyViewState extends State<DetectBodyView> {
  final BodyDetectModel _vm = BodyDetectModel();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vm.init();
  }

  Future<void> _startBodyScan() async {
    final file = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (context) => const BodyDetectGuidedCameraView(),
      ),
    );

    if (file == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _image = file;
    });

    await _vm.analyzeBody(file);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (_vm.error != null || _vm.topSize == null || _vm.bottomSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _vm.error ?? 'We couldn\'t read your body clearly. Please try again.',
                  style: AppFonts.montserrat14Regular64748B,
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    context.read<UserCubit>().setBodySizes(
          top: _vm.topSize!,
          bottom: _vm.bottomSize!,
        );

    await _showBodyResultDialog();
  }

  Future<void> _showBodyResultDialog() async {
    final gender = context.read<UserCubit>().gender ?? 'male';
    final isMale = gender != 'female';
    final color = isMale ? AppColors.primary : const Color(0xFFF973AF);
    final icon = isMale ? Icons.man_rounded : Icons.woman_rounded;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Your SmartFit size',
                style: AppFonts.montserrat18BoldBlack.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Top size: ${_vm.topSize}\nBottom size: ${_vm.bottomSize}',
                style: AppFonts.montserrat14Regular64748B,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Done',
                  backgroundColor: color,
                  showIcon: true,
                  icon: const Icon(Icons.check_rounded, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.appPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Smart Fit', style: AppFonts.montserrat18BoldBlack),
                SizedBox(height: 20),
                Text("Let's map your body", style: AppFonts.montserrat30BoldBlack, textAlign: TextAlign.center),
                SizedBox(height: 15),
                Text(
                  'Our AI analyzes your shape in seconds for personalized recommendations.',
                  style: AppFonts.montserrat14Regular64748B,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
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
                  height: 270,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : Image.asset('assets/images/detect_body_image.png', fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    InfoCardBodyDetect(assetPath: 'assets/images/hanger.png', title: 'Tight-fitting\nclothing'),
                    InfoCardBodyDetect(assetPath: 'assets/images/sun.png', title: 'Good\nlighting'),
                    InfoCardBodyDetect(assetPath: 'assets/images/person_stand.png', title: 'Stand\nfull body'),
                  ],
                ),
                SizedBox(height: 40),
                CustomButton(
                  onPressed: _isLoading ? () {} : _startBodyScan,
                  text: _isLoading ? 'Scanning...' : 'Start Body Scan',
                  showIcon: true,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.man_rounded, size: 18),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

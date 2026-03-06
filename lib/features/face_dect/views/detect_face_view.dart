import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/body_dect/views/detect_body_view.dart';
import 'package:smartfit/features/face_dect/model/gender_view_model.dart';
import 'package:smartfit/features/face_dect/widget/info_widget.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';

class DetectFaceView extends StatefulWidget {
  const DetectFaceView({super.key});

  @override
  State<DetectFaceView> createState() => _DetectFaceViewState();
}

class _DetectFaceViewState extends State<DetectFaceView> {
  final GenderViewModel _viewModel = GenderViewModel();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  Future<void> _startFaceScan() async {
    if (!_viewModel.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Model is still loading. Please wait...')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final file = File(picked.path);
      await _viewModel.detectGender(file);

      if (!mounted) return;

      if (_viewModel.gender == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
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
                    'We couldn\'t detect your face clearly. Please try again.',
                    style: AppFonts.montserrat14Regular64748B,
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      final rawGender = _viewModel.gender!.toLowerCase();
      final normalizedGender = rawGender.contains('female') ? 'female' : 'male';
      context.read<UserCubit>().setGender(normalizedGender);

      // Stop loading before showing the dialog so the button returns to normal.
      setState(() {
        _isLoading = false;
      });

      await _showResultDialog(normalizedGender);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong while scanning. Please try again.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showResultDialog(String gender) async {
    final isMale = gender == 'male';
    final color = isMale ? AppColors.primary : const Color(0xFFF973AF);
    final icon = isMale ? Icons.male_rounded : Icons.female_rounded;
    final label = isMale ? 'We detected: Male' : 'We detected: Female';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(label, style: AppFonts.montserrat18BoldBlack.copyWith(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'You can now continue to scan your body for even more accurate recommendations.',
                style: AppFonts.montserrat14Regular64748B,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DetectBodyView()));
                  },
                  text: 'Continue',
                  backgroundColor: color,
                  showIcon: true,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
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
                  height: 270,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/detect_face_image.png', fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InfoCardFaceDetect(assetPath: 'assets/images/sun.png', title: 'Good\nlighting'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoCardFaceDetect(assetPath: 'assets/images/sunglasses.png', title: 'Remove\nglasses'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                CustomButton(
                  onPressed: _isLoading ? () {} : _startFaceScan,
                  text: _isLoading ? 'Scanning...' : 'Start Face Scan',
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
                      : const Icon(Icons.face_unlock_outlined, size: 18),
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

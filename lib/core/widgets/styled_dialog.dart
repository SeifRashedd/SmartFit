import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';

class StyledDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback? onClose;

  const StyledDialog({super.key, required this.title, required this.message, required this.isSuccess, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSuccess ? AppColors.primary : Colors.red.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? AppColors.primary : Colors.red,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(title, style: AppFonts.montserrat16MediumBlack, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message, style: AppFonts.montserrat14Regular64748B, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                onClose?.call();
              },
              text: 'OK',
            ),
          ],
        ),
      ),
    );
  }
}

/// Show styled dialog helper function
void showStyledDialog(
  BuildContext context, {
  required String title,
  required String message,
  required bool isSuccess,
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) => StyledDialog(title: title, message: message, isSuccess: isSuccess, onClose: onClose),
  );
}

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

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 56),
            const SizedBox(height: 16),
            Text(title, style: AppFonts.montserrat16MediumBlack, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message, style: AppFonts.montserrat14Regular64748B, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(cancelText, style: AppFonts.montserrat16MediumBlack),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    text: confirmText,
                  ),
                ),
              ],
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

/// Show confirmation dialog helper function
void showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'No',
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );
}

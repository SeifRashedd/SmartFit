import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class HomeViewItem extends StatelessWidget {
  const HomeViewItem({
    super.key,
    required this.brand,
    required this.title,
    required this.price,
    required this.sizeLabel,
    required this.matchLabel,
    this.tagLabel,
  });

  final String brand;
  final String title;
  final String price;
  final String sizeLabel;
  final String matchLabel;
  final String? tagLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Container(width: double.infinity, color: const Color(0xFFE5F0FF)),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Pill(
                      label: matchLabel,
                      backgroundColor: const Color(0xFFE0F9FF),
                      textColor: AppColors.primary,
                    ),
                  ),
                  if (tagLabel != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _Pill(
                        label: tagLabel!,
                        backgroundColor: const Color(0xFFFFF4E5),
                        textColor: const Color(0xFFFB923C),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.montserrat13BoldPrimary.copyWith(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.montserrat14Regular64748B.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: AppFonts.montserrat14Regular64748B.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        sizeLabel,
                        style: AppFonts.montserrat13BoldPrimary.copyWith(fontSize: 11, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.backgroundColor, required this.textColor});

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.contains('%')) const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF38BDF8)),
          if (label.contains('%')) const SizedBox(width: 4),
          Text(label, style: AppFonts.montserrat13BoldPrimary.copyWith(fontSize: 10, color: textColor)),
        ],
      ),
    );
  }
}

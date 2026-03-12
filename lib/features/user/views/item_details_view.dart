import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';

class ItemDetailsView extends StatelessWidget {
  const ItemDetailsView({
    super.key,
    required this.brand,
    required this.title,
    required this.price,
    required this.sizeLabel,
    required this.matchLabel,
  });

  final String brand;
  final String title;
  final String price;
  final String sizeLabel;
  final String matchLabel;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFFE5F0FF))),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.43,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brand.toUpperCase(),
                                style: AppFonts.montserrat13BoldPrimary.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(title, style: AppFonts.montserrat20BoldBlack),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: AppFonts.montserrat14Regular64748B.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('(120 reviews)', style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(price, style: AppFonts.montserrat20BoldBlack),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: Icon(Icons.analytics_rounded, color: primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Sizing Analysis',
                                  style: AppFonts.montserrat13BoldPrimary.copyWith(color: const Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$matchLabel match for your profile. Based on your SmartFit size, we recommend $sizeLabel for a regular fit.',
                                  style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Is this right?',
                                  style: AppFonts.montserrat13BoldPrimary.copyWith(color: primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Recommended size: $sizeLabel',
                            style: AppFonts.montserrat13BoldPrimary.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

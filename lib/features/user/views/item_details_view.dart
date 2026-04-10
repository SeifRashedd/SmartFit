import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/cart_view.dart';

/// Demo-only: stable "random" rating + review count per product (no DB field yet).
({double rating, int reviewCount}) _fakeRatingReviews(String seed) {
  final random = Random(seed.hashCode);
  final rating = 3.9 + random.nextDouble() * 1.35; // ~3.9 – 4.95
  final reviewCount = 12 + random.nextInt(300); // 12 – 300
  return (rating: (rating * 10).round() / 10, reviewCount: reviewCount);
}

class ItemDetailsView extends StatelessWidget {
  const ItemDetailsView({
    super.key,
    required this.id,
    required this.brand,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.priceLabel,
    required this.isUpper,
    required this.sizeLabel,
    required this.matchLabel,
  });

  final String id;
  final String brand;
  final String title;
  final String description;
  final String imageUrl;
  final String priceLabel;

  /// `true` = top / upper body item → use [UserCubit.topSize]; else [UserCubit.bottomSize].
  final bool isUpper;
  final String sizeLabel;
  final String matchLabel;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final fake = _fakeRatingReviews('$brand|$title|$imageUrl');
    final userCubit = context.read<UserCubit>();
    final profileFit = isUpper ? userCubit.topSize : userCubit.bottomSize;
    final recommendedSize = (profileFit != null && profileFit.trim().isNotEmpty) ? profileFit.trim() : sizeLabel;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 230,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5F0FF)),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartView()),
                    ),
                  ),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      final count = context.watch<UserCubit>().cartItemIds.length;
                      if (count == 0) return const SizedBox.shrink();
                      
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: AppFonts.montserrat13BoldPrimary.copyWith(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.30,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
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
                                      fake.rating.toStringAsFixed(1),
                                      style: AppFonts.montserrat14Regular64748B.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${fake.reviewCount} reviews)',
                                      style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(priceLabel, style: AppFonts.montserrat20BoldBlack),
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
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
                                      '$matchLabel match for your profile. Based on your SmartFit size, we recommend $recommendedSize for a regular fit.',
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
                        Text(
                          description,
                          style: AppFonts.montserrat14Regular64748B.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
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
                                'Recommended size: $recommendedSize',
                                style: AppFonts.montserrat13BoldPrimary.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, state) {
                            final inCart = context.watch<UserCubit>().cartItemIds.contains(id);
                            
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<UserCubit>().toggleCartItem(id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: inCart ? const Color(0xFFFEE2E2) : primary,
                                  foregroundColor: inCart ? const Color(0xFFDC2626) : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: Icon(inCart ? Icons.remove_shopping_cart_rounded : Icons.add_shopping_cart_rounded),
                                label: Text(
                                  inCart ? 'Remove from Cart' : 'Add to Cart',
                                  style: AppFonts.montserrat14Regular64748B.copyWith(
                                    color: inCart ? const Color(0xFFDC2626) : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

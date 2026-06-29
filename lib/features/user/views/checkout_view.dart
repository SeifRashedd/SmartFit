import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/user/logic/cubit/models/clothes_model.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  String _brandLabel(ClothesModel item) {
    if (item.isUpper) {
      return item.isMale ? 'Men Top' : 'Women Top';
    }
    return item.isMale ? 'Men Bottom' : 'Women Bottom';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: AppFonts.montserrat20BoldBlack),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final cartItems = context.watch<UserCubit>().cartItems;

            if (cartItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppConstants.appPadding,
                  child: Text(
                    'Your cart is empty.',
                    style: AppFonts.montserrat14Regular64748B,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final total = cartItems.fold<double>(0, (sum, e) => sum + e.price);
            final totalLabel = '\$${total.toStringAsFixed(2)}';

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: AppConstants.appPadding,
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CheckoutItemRow(
                        brand: _brandLabel(item),
                        item: item,
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: AppConstants.appPadding.copyWith(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'})',
                            style: AppFonts.montserrat14Regular64748B.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(totalLabel, style: AppFonts.montserrat20BoldBlack),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Pay',
                        showIcon: true,
                        icon: const Icon(Icons.lock_outline_rounded, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({
    required this.brand,
    required this.item,
  });

  final String brand;
  final ClothesModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppColors.primary.withValues(alpha: 0.08),
                child: const Icon(Icons.checkroom_outlined, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: AppFonts.montserrat14Regular64748B.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: AppFonts.montserrat14Regular64748B.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size ${item.size}',
                  style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.formattedPrice,
            style: AppFonts.montserrat14Regular64748B.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

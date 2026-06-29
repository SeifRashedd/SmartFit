import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/checkout_view.dart';
import 'package:smartfit/features/user/views/item_details_view.dart';
import 'package:smartfit/features/user/widgets/home_view_item.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    const staticMatchLabel = '98% Match';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart', style: AppFonts.montserrat20BoldBlack),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final cubit = context.watch<UserCubit>();
            final cartItems = cubit.cartItems;

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

            final cartTotal = cartItems.fold<double>(0, (sum, e) => sum + e.price);
            final totalLabel = '\$${cartTotal.toStringAsFixed(2)}';
            final cap = cubit.totalCartBudget;
            final capLabel = (cap != null && cap > 0) ? '\$${cap.toStringAsFixed(2)}' : null;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: AppConstants.appPadding,
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = cartItems[index];
                      final brand = item.isUpper
                          ? (item.isMale ? 'Men Top' : 'Women Top')
                          : (item.isMale ? 'Men Bottom' : 'Women Bottom');

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailsView(
                                id: item.id,
                                brand: brand,
                                title: item.title,
                                description: item.description,
                                imageUrl: item.image,
                                priceLabel: item.formattedPrice,
                                isUpper: item.isUpper,
                                sizeLabel: item.size,
                                matchLabel: staticMatchLabel,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            HomeViewItem(
                              brand: brand,
                              title: item.title,
                              description: item.description,
                              priceLabel: item.formattedPrice,
                              imageUrl: item.image,
                              sizeLabel: item.size,
                              matchLabel: staticMatchLabel,
                              tagLabel: item.isUpper ? 'Top Pick' : null,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  context.read<UserCubit>().toggleCartItem(item.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: cartItems.length),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.60,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppConstants.appPadding.copyWith(top: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text(
                                totalLabel,
                                style: AppFonts.montserrat20BoldBlack,
                              ),
                            ],
                          ),
                          if (capLabel != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Your cart budget limit: $capLabel',
                              style: AppFonts.montserrat14Regular64748B.copyWith(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppConstants.appPadding.copyWith(top: 8),
                    child: CustomButton(
                      text: 'Checkout',
                      showIcon: true,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutView()),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

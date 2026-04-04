import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
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
              ],
            );
          },
        ),
      ),
    );
  }
}

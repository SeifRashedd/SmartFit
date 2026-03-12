import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/user/views/item_details_view.dart';
import 'package:smartfit/features/user/widgets/home_view_item.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _demoItems;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppConstants.appPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'We found the best clothes for you',
                      textAlign: TextAlign.center,
                      style: AppFonts.montserrat20BoldBlack,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Based on your body, budget and style.',
                      textAlign: TextAlign.start,
                      style: AppFonts.montserrat14Regular64748B,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: AppConstants.appPadding.copyWith(top: 0),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ItemDetailsView(
                              brand: item.brand,
                              title: item.title,
                              price: item.price,
                              sizeLabel: item.sizeLabel,
                              matchLabel: item.matchLabel,
                            ),
                          ),
                        );
                      },
                      child: HomeViewItem(
                        brand: item.brand,
                        title: item.title,
                        price: item.price,
                        sizeLabel: item.sizeLabel,
                        matchLabel: item.matchLabel,
                        tagLabel: item.tagLabel,
                      ),
                    );
                  },
                  childCount: items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.60,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}

class _HomeDemoItem {
  _HomeDemoItem({
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
}

final List<_HomeDemoItem> _demoItems = [
  _HomeDemoItem(
    brand: 'Everlane',
    title: 'Linen Relaxed Shirt',
    price: '\$68.00',
    sizeLabel: 'Size M',
    matchLabel: '98% Match',
    tagLabel: 'Top Pick',
  ),
  _HomeDemoItem(
    brand: 'Bonobos',
    title: 'Slim Fit Chino',
    price: '\$98.00',
    sizeLabel: '32x30',
    matchLabel: 'Best Length',
  ),
  _HomeDemoItem(
    brand: 'Uniqlo',
    title: 'Merino Wool Sweater',
    price: '\$49.90',
    sizeLabel: 'Size M',
    matchLabel: 'Top Pick',
  ),
  _HomeDemoItem(
    brand: 'Ralph Lauren',
    title: 'Classic Oxford',
    price: '\$89.50',
    sizeLabel: 'Size M',
    matchLabel: '95% Match',
  ),
  _HomeDemoItem(
    brand: 'Levi\'s',
    title: 'Trucker Jacket',
    price: '\$98.00',
    sizeLabel: 'Size L',
    matchLabel: 'Perfect Fit',
  ),
  _HomeDemoItem(
    brand: 'Patagonia',
    title: 'Baggies Shorts',
    price: '\$65.00',
    sizeLabel: 'Size M',
    matchLabel: 'Fit Check',
  ),
];

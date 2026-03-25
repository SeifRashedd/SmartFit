import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/features/body_dect/views/detect_body_view.dart';
import 'package:smartfit/features/face_dect/views/detect_face_view.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/item_details_view.dart';
import 'package:smartfit/features/user/widgets/home_view_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().getUserClothes();
    });
  }

  @override
  Widget build(BuildContext context) {
    const staticPrice = '\$45.00';
    const staticMatchLabel = '98% Match';

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text('Scan Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                ListTile(
                  leading: const Icon(Icons.face_rounded),
                  title: const Text('Scan Face Again'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const DetectFaceView(goToBodyAfterScan: false)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.accessibility_new_rounded),
                  title: const Text('Scan Body Again'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DetectBodyView()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.repeat_rounded),
                  title: const Text('Scan Both (Face + Body)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DetectFaceView()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final clothes = state is GetUserClothesSuccessState ? state.clothes : null;

            final errorMsg = switch (state) {
              GetUserClothesErrorState s => s.errMsg,
              GetUserClothesExceptionState s => s.errMsg,
              _ => null,
            };

            final isLoading = state is GetUserClothesLoadingState;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppConstants.appPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (innerContext) => IconButton(
                              onPressed: () => Scaffold.of(innerContext).openDrawer(),
                              icon: const Icon(Icons.menu_rounded),
                            ),
                          ),
                        ),
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
                if (errorMsg != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppConstants.appPadding,
                      child: Text(
                        errorMsg,
                        style: AppFonts.montserrat14Regular64748B.copyWith(color: const Color(0xFFE11D48)),
                      ),
                    ),
                  )
                else if (isLoading)
                  SliverPadding(
                    padding: AppConstants.appPadding.copyWith(top: 0),
                    sliver: const _HomeShimmerSliverGrid(count: 6),
                  )
                else if (clothes == null || clothes.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppConstants.appPadding,
                      child: Text('No clothes found.', style: AppFonts.montserrat14Regular64748B),
                    ),
                  )
                else
                  SliverPadding(
                    padding: AppConstants.appPadding.copyWith(top: 0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = clothes[index];
                        final brand = item.isUpper
                            ? (item.isMale ? 'Men Top' : 'Women Top')
                            : (item.isMale ? 'Men Bottom' : 'Women Bottom');

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailsView(
                                  brand: brand,
                                  title: item.title,
                                  description: item.description,
                                  imageUrl: item.image,
                                  price: staticPrice,
                                  isUpper: item.isUpper,
                                  sizeLabel: item.size,
                                  matchLabel: staticMatchLabel,
                                ),
                              ),
                            );
                          },
                          child: HomeViewItem(
                            brand: brand,
                            title: item.title,
                            description: item.description,
                            imageUrl: item.image,
                            price: staticPrice,
                            sizeLabel: item.size,
                            matchLabel: staticMatchLabel,
                            tagLabel: item.isUpper ? 'Top Pick' : null,
                          ),
                        );
                      }, childCount: clothes.length),
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
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}

class _HomeShimmerSliverGrid extends StatefulWidget {
  const _HomeShimmerSliverGrid({required this.count});

  final int count;

  @override
  State<_HomeShimmerSliverGrid> createState() => _HomeShimmerSliverGridState();
}

class _HomeShimmerSliverGridState extends State<_HomeShimmerSliverGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value; // 0..1

        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) => _HomeShimmerTile(t: t), childCount: widget.count),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.60,
          ),
        );
      },
    );
  }
}

class _HomeShimmerTile extends StatelessWidget {
  const _HomeShimmerTile({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFFE5E7EB);
    final highlight = const Color(0xFFF1F5F9);
    final dx = -1.0 + 2.0 * t; // -1..1

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final topH = h * 0.50;

        Widget shimmerBox({required double height}) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(dx, 0),
                  end: Alignment(dx + 0.9, 0),
                  colors: [base, highlight, base],
                ),
              ),
            ),
          );
        }

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
              SizedBox(
                height: topH,
                width: double.infinity,
                child: shimmerBox(height: topH),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(height: 10),
                    const SizedBox(height: 6),
                    shimmerBox(height: 26),
                    const SizedBox(height: 6),
                    shimmerBox(height: 14),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: constraints.maxWidth * 0.45, child: shimmerBox(height: 12)),
                        SizedBox(
                          width: constraints.maxWidth * 0.30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 26,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(dx, 0),
                                  end: Alignment(dx + 0.9, 0),
                                  colors: [base, highlight, base],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

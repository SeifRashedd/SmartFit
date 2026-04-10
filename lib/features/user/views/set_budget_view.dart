import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/home_view.dart';

class SetBudgetView extends StatefulWidget {
  const SetBudgetView({super.key, this.isFromDrawer = false});

  final bool isFromDrawer;

  @override
  State<SetBudgetView> createState() => _SetBudgetViewState();
}

class _SetBudgetViewState extends State<SetBudgetView> {
  static const double _min = UserCubit.budgetMinUsd;
  static const double _max = UserCubit.budgetMaxUsd;

  late RangeValues _values;
  int? _selectedQuickIndex;
  late final TextEditingController _totalCartBudgetController;

  @override
  void initState() {
    super.initState();
    final userCubit = context.read<UserCubit>();

    final minBudget = userCubit.minBudget ?? 300;
    final maxBudget = userCubit.maxBudget ?? 500;

    _values = RangeValues(minBudget.clamp(_min, _max), maxBudget.clamp(_min, _max));

    _selectedQuickIndex = switch (userCubit.budgetSegment) {
      'range_200_300' => 0,
      'range_300_400' => 1,
      'range_400_500' => 2,
      'range_200_500' => 3,
      _ => null,
    };

    final existingCap = userCubit.totalCartBudget;
    _totalCartBudgetController = TextEditingController(
      text: (existingCap != null && existingCap > 0)
          ? existingCap.toStringAsFixed(existingCap == existingCap.roundToDouble() ? 0 : 2)
          : '',
    );
  }

  @override
  void dispose() {
    _totalCartBudgetController.dispose();
    super.dispose();
  }

  void _onQuickSelect(int index) {
    setState(() {
      _selectedQuickIndex = index;

      switch (index) {
        case 0:
          _values = const RangeValues(200, 300);
          break;
        case 1:
          _values = const RangeValues(300, 400);
          break;
        case 2:
          _values = const RangeValues(400, 500);
          break;
        case 3:
          _values = const RangeValues(200, 500);
          break;
      }
    });
  }

  String _segmentKeyForIndex(int? index) {
    return switch (index) {
      0 => 'range_200_300',
      1 => 'range_300_400',
      2 => 'range_400_500',
      3 => 'range_200_500',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (widget.isFromDrawer) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(
                          context,
                        ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeView()), (route) => false);
                      }
                    },
                    child: Text('Skip', style: AppFonts.montserrat14Regular64748B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Set Your Budget', style: AppFonts.montserrat30BoldBlack),
              const SizedBox(height: 8),
              Text(
                'Select a price range so we can personalize your wardrobe options.',
                style: AppFonts.montserrat14Regular64748B,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 12)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '\$${_values.start.round()} - \$${_values.end.round()}',
                      style: AppFonts.montserrat30BoldBlack.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Average spend per outfit',
                      style: AppFonts.montserrat13BoldPrimary.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              RangeSlider(
                min: _min,
                max: _max,
                activeColor: primary,
                inactiveColor: primary.withValues(alpha: 0.2),
                values: _values,
                onChanged: (values) {
                  setState(() {
                    _values = values;
                    _selectedQuickIndex = null;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${_min.round()}', style: AppFonts.montserrat13BoldPrimary),
                    Text('\$${_max.round()}', style: AppFonts.montserrat13BoldPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Quick Select', style: AppFonts.montserrat14Regular64748B.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _BudgetChip(
                    label: '\$200 - \$300',
                    isSelected: _selectedQuickIndex == 0,
                    onTap: () => _onQuickSelect(0),
                  ),
                  _BudgetChip(
                    label: '\$300 - \$400',
                    isSelected: _selectedQuickIndex == 1,
                    onTap: () => _onQuickSelect(1),
                  ),
                  _BudgetChip(
                    label: '\$400 - \$500',
                    isSelected: _selectedQuickIndex == 2,
                    onTap: () => _onQuickSelect(2),
                  ),
                  _BudgetChip(
                    label: '\$200 - \$500',
                    isSelected: _selectedQuickIndex == 3,
                    onTap: () => _onQuickSelect(3),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total budget for your whole cart',
                  style: AppFonts.montserrat14Regular64748B.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We will warn you when adding items would go over this total (sum of all items in your cart).',
                style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 12),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _totalCartBudgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppFonts.montserrat14Regular64748B.copyWith(color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: '\$ 1500',
                  hintStyle: AppFonts.montserrat14Regular64748B,
                  prefixText: '\$ ',
                  prefixStyle: AppFonts.montserrat14Regular64748B.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary.withValues(alpha: 0.18)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Find My Style',
                showIcon: true,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () async {
                  final raw = _totalCartBudgetController.text.trim().replaceAll(RegExp(r'[\$,]'), '');
                  final totalCap = double.tryParse(raw);
                  if (totalCap == null || totalCap <= 0) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Enter a valid total cart budget.')));
                    return;
                  }

                  final segmentKey = _segmentKeyForIndex(_selectedQuickIndex);
                  final cubit = context.read<UserCubit>();
                  if (totalCap + 1e-6 < cubit.cartSubtotal) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Your cart is \$${cubit.cartSubtotal.toStringAsFixed(2)}. Enter a limit that covers it, or remove items first.',
                        ),
                      ),
                    );
                    return;
                  }

                  await cubit.setBudget(
                    min: _values.start,
                    max: _values.end,
                    segment: segmentKey.isEmpty ? null : segmentKey,
                    totalCartBudgetMax: totalCap,
                  );
                  await cubit.getUserClothes();

                  if (!context.mounted) return;
                  if (widget.isFromDrawer) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(
                      context,
                    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeView()), (route) => false);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF3F5F8),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  const _BudgetChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : const Color(0xFF94A3B8).withValues(alpha: 0.3);
    final textStyle = isSelected
        ? AppFonts.montserrat13BoldPrimary.copyWith(color: AppColors.primary)
        : AppFonts.montserrat14Regular64748B;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: 1.3),
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}

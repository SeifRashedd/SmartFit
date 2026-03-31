import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/face_dect/views/detect_face_view.dart';
import 'package:smartfit/features/user/logic/cubit/user_cubit.dart';
import 'package:smartfit/features/user/views/login_view.dart';
// import 'package:smartfit/features/user/views/home_view.dart';

class SetBudgetView extends StatefulWidget {
  const SetBudgetView({super.key});

  @override
  State<SetBudgetView> createState() => _SetBudgetViewState();
}

class _SetBudgetViewState extends State<SetBudgetView> {
  static const double _min = 0;
  static const double _max = 500;

  late RangeValues _values;
  int? _selectedQuickIndex;

  @override
  void initState() {
    super.initState();
    final userCubit = context.read<UserCubit>();

    final minBudget = userCubit.minBudget ?? 50;
    final maxBudget = userCubit.maxBudget ?? 200;

    _values = RangeValues(minBudget.clamp(_min, _max), maxBudget.clamp(_min, _max));

    _selectedQuickIndex = switch (userCubit.budgetSegment) {
      'under_50' => 0,
      'mid_50_200' => 1,
      'premium' => 2,
      'luxury' => 3,
      _ => null,
    };
  }

  void _onQuickSelect(int index) {
    setState(() {
      _selectedQuickIndex = index;

      switch (index) {
        case 0:
          _values = const RangeValues(0, 50);
          break;
        case 1:
          _values = const RangeValues(50, 200);
          break;
        case 2:
          _values = const RangeValues(200, 350);
          break;
        case 3:
          _values = const RangeValues(350, 500);
          break;
      }
    });
  }

  String _segmentKeyForIndex(int? index) {
    return switch (index) {
      0 => 'under_50',
      1 => 'mid_50_200',
      2 => 'premium',
      3 => 'luxury',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.appPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginView())),
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
                    Text('\$0', style: AppFonts.montserrat13BoldPrimary),
                    Text('\$500+', style: AppFonts.montserrat13BoldPrimary),
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
                    label: 'Under \$50',
                    isSelected: _selectedQuickIndex == 0,
                    onTap: () => _onQuickSelect(0),
                  ),
                  _BudgetChip(
                    label: '\$50 - \$200',
                    isSelected: _selectedQuickIndex == 1,
                    onTap: () => _onQuickSelect(1),
                  ),
                  _BudgetChip(label: 'Premium', isSelected: _selectedQuickIndex == 2, onTap: () => _onQuickSelect(2)),
                  _BudgetChip(label: 'Luxury', isSelected: _selectedQuickIndex == 3, onTap: () => _onQuickSelect(3)),
                ],
              ),
              const Spacer(),
              CustomButton(
                text: 'Find My Style',
                showIcon: true,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () {
                  final segmentKey = _segmentKeyForIndex(_selectedQuickIndex);
                  context.read<UserCubit>().setBudget(
                    min: _values.start,
                    max: _values.end,
                    segment: segmentKey.isEmpty ? null : segmentKey,
                  );

                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DetectFaceView()));
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

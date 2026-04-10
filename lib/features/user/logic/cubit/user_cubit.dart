import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/clothes_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  static const _kSeenOnboarding = 'seen_onboarding';
  static const _kGender = 'user_gender';
  static const _kTopSize = 'user_top_size';
  static const _kBottomSize = 'user_bottom_size';
  static const _kMinBudget = 'user_min_budget';
  static const _kMaxBudget = 'user_max_budget';
  static const _kBudgetSegment = 'user_budget_segment';
  static const _kCartItems = 'cart_items';

  static const double budgetMinUsd = 200;
  static const double budgetMaxUsd = 500;

  SharedPreferences? _prefs;

  bool hasSeenOnboarding = false;
  String? gender; // 'male' or 'female'
  String? topSize;
  String? bottomSize;
  double? minBudget;
  double? maxBudget;
  String? budgetSegment;
  List<ClothesModel> clothes = [];
  List<ClothesModel> clothesAfterFillter = [];
  List<String> cartItemIds = [];

  List<ClothesModel> get cartItems => clothes.where((e) => cartItemIds.contains(e.id)).toList();

  Future<void> initData() async {
    _prefs = await SharedPreferences.getInstance();

    hasSeenOnboarding = _prefs?.getBool(_kSeenOnboarding) ?? false;
    gender = _prefs?.getString(_kGender);
    topSize = _prefs?.getString(_kTopSize);
    bottomSize = _prefs?.getString(_kBottomSize);
    cartItemIds = _prefs?.getStringList(_kCartItems) ?? [];

    minBudget = _prefs?.getDouble(_kMinBudget);
    maxBudget = _prefs?.getDouble(_kMaxBudget);
    budgetSegment = _prefs?.getString(_kBudgetSegment);
    _clampBudgetToAllowedRange();

    emit(UserDataInitialized());
  }

  Future<void> setOnboardingSeen() async {
    hasSeenOnboarding = true;
    await _prefs?.setBool(_kSeenOnboarding, true);
    emit(UserDataInitialized());
  }

  void setGender(String value) {
    gender = value;
    _prefs?.setString(_kGender, value);
    filtterClothes();
    emit(UserGenderUpdated(value));
  }

  void setBodySizes({required String top, required String bottom}) {
    topSize = top;
    bottomSize = bottom;
    _prefs?.setString(_kTopSize, top);
    _prefs?.setString(_kBottomSize, bottom);
    emit(UserBodyUpdated(topSize: top, bottomSize: bottom));
  }

  void _clampBudgetToAllowedRange() {
    if (minBudget == null && maxBudget == null) return;
    var lo = (minBudget ?? budgetMinUsd).clamp(budgetMinUsd, budgetMaxUsd);
    var hi = (maxBudget ?? budgetMaxUsd).clamp(budgetMinUsd, budgetMaxUsd);
    if (lo > hi) {
      final t = lo;
      lo = hi;
      hi = t;
    }
    minBudget = lo;
    maxBudget = hi;
  }

  Future<void> setBudget({required double min, required double max, String? segment}) async {
    var lo = min.clamp(budgetMinUsd, budgetMaxUsd);
    var hi = max.clamp(budgetMinUsd, budgetMaxUsd);
    if (lo > hi) {
      final t = lo;
      lo = hi;
      hi = t;
    }
    minBudget = lo;
    maxBudget = hi;
    budgetSegment = segment;
    await _prefs?.setDouble(_kMinBudget, lo);
    await _prefs?.setDouble(_kMaxBudget, hi);
    if (segment != null && segment.isNotEmpty) {
      await _prefs?.setString(_kBudgetSegment, segment);
    } else {
      await _prefs?.remove(_kBudgetSegment);
    }
    filtterClothes();
    emit(UserBudgetUpdated(minBudget: minBudget!, maxBudget: maxBudget!, segment: budgetSegment));
  }

  void toggleCartItem(String id) {
    if (cartItemIds.contains(id)) {
      cartItemIds.remove(id);
    } else {
      cartItemIds.add(id);
    }
    _prefs?.setStringList(_kCartItems, cartItemIds);
    emit(UserCartUpdated());
  }


  void filtterClothes() {
    Iterable<ClothesModel> list = clothes;

    final normalizedGender = (gender ?? '').toLowerCase();
    if (normalizedGender == 'male') {
      list = list.where((item) => item.isMale);
    } else if (normalizedGender == 'female') {
      list = list.where((item) => !item.isMale);
    }

    final minB = minBudget;
    final maxB = maxBudget;
    if (minB != null && maxB != null) {
      var lo = minB <= maxB ? minB : maxB;
      var hi = minB <= maxB ? maxB : minB;
      list = list.where((item) => item.price >= lo && item.price <= hi);
    }

    clothesAfterFillter = list.toList();
  }

  Future<void> getUserClothes() async {
    emit(GetUserClothesLoadingState());
    try {
      final result = await Supabase.instance.client.from('clothes').select('*');
      final dynamic data = (() {
        try {
          final maybeData = (result as dynamic).data;
          return maybeData ?? result;
        } catch (_) {
          return result;
        }
      })();

      final parsedClothes = <ClothesModel>[];
      if (data is List) {
        for (final item in data) {
          if (item is Map) {
            parsedClothes.add(ClothesModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      clothes = parsedClothes;
      filtterClothes();
      emit(GetUserClothesSuccessState(clothes: clothesAfterFillter));
    } on AssertionError {
      // Happens when `Supabase.initialize(...)` was not called in `main.dart`.
      emit(
        GetUserClothesExceptionState(
          errMsg: 'Supabase is not initialized. Please call Supabase.initialize in main.dart.',
        ),
      );
    } catch (e) {
      emit(GetUserClothesExceptionState(errMsg: e.toString()));
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    // Clear user-specific data but preserve onboarding status
    await _prefs?.remove(_kGender);
    await _prefs?.remove(_kTopSize);
    await _prefs?.remove(_kBottomSize);
    await _prefs?.remove(_kMinBudget);
    await _prefs?.remove(_kMaxBudget);
    await _prefs?.remove(_kBudgetSegment);
    await _prefs?.remove('remember_me'); // Clear remember me on logout

    gender = null;
    topSize = null;
    bottomSize = null;
    minBudget = null;
    maxBudget = null;
    budgetSegment = null;
    clothes.clear();
    clothesAfterFillter.clear();
    emit(UserLoggedOut());
  }
}

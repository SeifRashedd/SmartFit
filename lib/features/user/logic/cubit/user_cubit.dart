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

  Future<void> initData() async {
    _prefs = await SharedPreferences.getInstance();

    hasSeenOnboarding = _prefs?.getBool(_kSeenOnboarding) ?? false;
    gender = _prefs?.getString(_kGender);
    topSize = _prefs?.getString(_kTopSize);
    bottomSize = _prefs?.getString(_kBottomSize);

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

  void setBudget({required double min, required double max, String? segment}) {
    minBudget = min;
    maxBudget = max;
    budgetSegment = segment;
    emit(UserBudgetUpdated(minBudget: minBudget!, maxBudget: maxBudget!, segment: budgetSegment));
  }

  void filtterClothes() {
    final normalizedGender = (gender ?? '').toLowerCase();
    if (normalizedGender == 'male') {
      clothesAfterFillter = clothes.where((item) => item.isMale).toList();
      return;
    }
    if (normalizedGender == 'female') {
      clothesAfterFillter = clothes.where((item) => !item.isMale).toList();
      return;
    }
    clothesAfterFillter = List<ClothesModel>.from(clothes);
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
            parsedClothes.add(
              ClothesModel.fromJson(Map<String, dynamic>.from(item)),
            );
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
}

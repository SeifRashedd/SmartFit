import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/clothes_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  String? gender; // 'male' or 'female'
  String? topSize;
  String? bottomSize;
  double? minBudget;
  double? maxBudget;
  String? budgetSegment;
  List<ClothesModel> clothes = [];

  void setGender(String value) {
    gender = value;
    emit(UserGenderUpdated(value));
  }

  void setBodySizes({required String top, required String bottom}) {
    topSize = top;
    bottomSize = bottom;
    emit(UserBodyUpdated(topSize: top, bottomSize: bottom));
  }

  void setBudget({required double min, required double max, String? segment}) {
    minBudget = min;
    maxBudget = max;
    budgetSegment = segment;
    emit(UserBudgetUpdated(minBudget: minBudget!, maxBudget: maxBudget!, segment: budgetSegment));
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
      emit(GetUserClothesSuccessState(clothes: parsedClothes));
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

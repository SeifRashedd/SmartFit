import 'package:bloc/bloc.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  String? gender; // 'male' or 'female'
  String? topSize;
  String? bottomSize;
  double? minBudget;
  double? maxBudget;
  String? budgetSegment;

  void setGender(String value) {
    gender = value;
    emit(UserGenderUpdated(value));
  }

  void setBodySizes({
    required String top,
    required String bottom,
  }) {
    topSize = top;
    bottomSize = bottom;
    emit(UserBodyUpdated(topSize: top, bottomSize: bottom));
  }

  void setBudget({
    required double min,
    required double max,
    String? segment,
  }) {
    minBudget = min;
    maxBudget = max;
    budgetSegment = segment;
    emit(
      UserBudgetUpdated(
        minBudget: minBudget!,
        maxBudget: maxBudget!,
        segment: budgetSegment,
      ),
    );
  }
}

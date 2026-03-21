part of 'user_cubit.dart';

sealed class UserState {}

final class UserInitial extends UserState {}
final class UserDataInitialized extends UserState {}

final class UserGenderUpdated extends UserState {
  UserGenderUpdated(this.gender);

  final String gender;
}

final class UserBodyUpdated extends UserState {
  UserBodyUpdated({required this.topSize, required this.bottomSize});

  final String topSize;
  final String bottomSize;
}

final class UserBudgetUpdated extends UserState {
  UserBudgetUpdated({required this.minBudget, required this.maxBudget, this.segment});

  final double minBudget;
  final double maxBudget;
  final String? segment;
}

class GetUserClothesLoadingState extends UserState {}

class GetUserClothesSuccessState extends UserState {
  GetUserClothesSuccessState({required this.clothes});

  final List<ClothesModel> clothes;
}

class GetUserClothesErrorState extends UserState {
  final String errMsg;
  GetUserClothesErrorState({required this.errMsg});
}

class GetUserClothesExceptionState extends UserState {
  final String errMsg;
  GetUserClothesExceptionState({required this.errMsg});
}
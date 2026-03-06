part of 'user_cubit.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

final class UserGenderUpdated extends UserState {
  UserGenderUpdated(this.gender);

  final String gender;
}

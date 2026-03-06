import 'package:bloc/bloc.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  String? gender; // 'male' or 'female'

  void setGender(String value) {
    gender = value;
    emit(UserGenderUpdated(value));
  }
}

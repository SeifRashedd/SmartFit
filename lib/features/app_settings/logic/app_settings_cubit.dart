import 'package:bloc/bloc.dart';

part 'app_settings_state.dart';

class AppSettingCubit extends Cubit<AppSettingsState> {
  AppSettingCubit() : super(AppSettingInitial());

  final List<Map<String, dynamic>> onBoardingScreens = [
    {
      'img': 'assets/images/onBording1.png',
      'title': 'Find the Right Gym for You',
      'description':
          'Browse a wide range of gyms, studios, and fitness spaces in your area —all in one app.',
    },
    {
      'img': 'assets/images/onBording2.png',
      'title': 'View & Book Services Instantly',
      'description':
          'From group classes to personal training, discover what each gym offers.',
    },
    {
      'img': 'assets/images/onBording3.png',
      'title': 'All Your Bookings in One Place',
      'description':
          'Track upcoming sessions, manage your schedule, and never miss a workout.',
    },
  ];

  int _selectedOnBoardingScreen = 0;
  int get selectedOnBoardingScreen => _selectedOnBoardingScreen;

  void changeOnboardingScreen() {
    if (_selectedOnBoardingScreen < 2) {
      _selectedOnBoardingScreen++;
      emit(OnBoardingState());
    }
  }

  int _bottomNavCurrentIndex = 0;
  int get bottomNavCurrentIndex => _bottomNavCurrentIndex;

  void changeTab(int index) {
    _bottomNavCurrentIndex = index;
    emit(ChangeScreenState());
  }
}

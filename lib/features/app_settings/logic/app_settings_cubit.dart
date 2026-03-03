import 'package:bloc/bloc.dart';

part 'app_settings_state.dart';

class AppSettingCubit extends Cubit<AppSettingsState> {
  AppSettingCubit() : super(AppSettingInitial());

  final List<Map<String, dynamic>> onBoardingScreens = [
    {
      'img': 'assets/images/onbording1.png',
      'title': 'Perfect Fit, Every Time.',
      'description':
          'Our AI analyzes your unique measurements to recommend the size that actually fits you.',
    },
    {
      'img': 'assets/images/onbording2.png',
      'title': 'AI-Powered Recommendations',
      'description':
          'Our intelligent algorithms learn your style and body type to suggest clothes you\'ll love.',
    },
    {
      'img': 'assets/images/onbording3.png',
      'title': 'Ready for Your Perfect Fit?',
      'description':
          'Join thousands of shoppers who found their perfect size with SmartFit AI.',
    },
  ];

  int _selectedOnBoardingScreen = 0;
  int get selectedOnBoardingScreen => _selectedOnBoardingScreen;

  void setOnboardingScreen(int index) {
    if (index < 0 || index >= onBoardingScreens.length) return;
    if (_selectedOnBoardingScreen == index) return;
    _selectedOnBoardingScreen = index;
    emit(OnBoardingState());
  }

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

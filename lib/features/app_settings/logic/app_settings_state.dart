part of 'app_settings_cubit.dart';

sealed class AppSettingsState {}

class AppSettingInitial extends AppSettingsState {}

class ChangeScreenState extends AppSettingsState {}

class OnBoardingState extends AppSettingsState {}

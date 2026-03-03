import 'package:flutter/material.dart';
import 'package:smartfit/core/styles/app_colors.dart';

class AppFonts {
  static const String montserrat = 'Montserrat';
  static const Color c64748B = Color(0xFF64748B);

  static TextStyle get montserrat24MediumWhite => TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat30BoldBlack => TextStyle(
    color: Colors.black,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat13RegularBlack=> TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat30BoldPrimary => TextStyle(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    fontFamily: montserrat,
  );


  static TextStyle get montserrat14Regular64748B => TextStyle(
    fontFamily: montserrat,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: c64748B,
  );

  static TextStyle get montserrat18RegularWhite => TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat18MediumWhite => TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat14MediumBlue => TextStyle(
    color: const Color(0xff2A80E2),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat16RegulayWhite => TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat16MediumWhite => TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get montserrat17RegularWhite => TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontFamily: montserrat,
  );

  static TextStyle get montserrat16MediumBlack => TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle get montserrat10RegularWhite => TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    fontFamily: montserrat,
  );
}

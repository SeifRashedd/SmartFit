import 'package:flutter/material.dart';

class AppFonts {
  static const String montserrat = 'Montserrat';

  static TextStyle get montserrat24MediumWhite => TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    fontFamily: montserrat,
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

//Chứa định nghĩa màu sắc, typography, các ThemeData của ứng dụng. (chính)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluishClr = Color(0xFF4e5ae8);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
Color darkHeaderClr = Color(0xFF424242);

class Themes {
  //light
  static final light = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryClr,
    brightness: Brightness.light,
    // scaffoldBackgroundColor: Colors.white, // Thiết lập màu nền trắng cho toàn bộ scaffold (giao diện chính)
    // scaffoldBackgroundColor: Color(0xffE2EAFF), //màu nền chung cho cả 4 màn hình chính là màu xám
  );

  //dark
  static final dark = ThemeData(
    scaffoldBackgroundColor: darkGreyClr,
    primaryColor: darkGreyClr,
    brightness: Brightness.dark,
  );
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode ? Colors.grey[400] : Colors.grey,
    ),
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode ? Colors.white : Colors.black,
    ),
  );
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? Colors.white : Colors.black,
    ),
  );
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[600],
    ),
  );
}

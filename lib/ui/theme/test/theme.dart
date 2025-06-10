// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// const Color bluishClr = Color(0xFF4e5ae8);
// const Color yellowClr = Color(0xFFFFB746);
// const Color pinkClr = Color(0xFFff4667);
// const Color white = Colors.white;
// const primaryClr = bluishClr;
// const Color darkGreyClr = Color(0xFF121212);
// Color darkHeaderClr = Color(0xFF424242);
//
// //test
// class Themes {
//
//   //light
//  static final light =   ThemeData(
//   primaryColor: primaryClr,
//   brightness: Brightness.light,
//   // scaffoldBackgroundColor: Colors.white, // Thiết lập màu nền trắng cho toàn bộ scaffold (giao diện chính)
//   // scaffoldBackgroundColor: Color(0xffE2EAFF), //màu nền chung cho cả 4 màn hình chính là màu xám
//  );
//
//  //dark
//  static final dark = ThemeData(
//   primaryColor: darkGreyClr,
//   brightness: Brightness.dark,
//   );
// }
//
// TextStyle get subHeadingStyle {
//   return GoogleFonts.lato (
//     textStyle: TextStyle(
//       fontSize: 24,
//       fontWeight: FontWeight.bold,
//       color: Get.isDarkMode?Colors.grey[400] :  Colors.grey
//     )
//   );
// }
//
// TextStyle get headingStyle {
//   return GoogleFonts.lato (
//       textStyle: TextStyle(
//         fontSize: 30,
//         fontWeight: FontWeight.bold,
//           color: Get.isDarkMode?Colors.white:  Colors.black
//       )
//   );
// }
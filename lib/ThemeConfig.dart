import 'package:flutter/material.dart';

import 'constant/ColorConstant.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    //1
    return ThemeData(
        primaryColor: CustomColor.themeColor,
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: CustomColor.themeColor,
        ),
        appBarTheme: AppBarTheme(color: CustomColor.themeColor, elevation: 0),
        iconTheme: IconThemeData(color: Colors.white));
  }

  static ThemeData get darkTheme {
    return ThemeData(
        primaryColor: CustomColor.themeColor,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Montserrat',
        textTheme: ThemeData.dark().textTheme,
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: CustomColor.themeColor,
        ));
  }
}

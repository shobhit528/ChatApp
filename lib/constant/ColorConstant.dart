import 'dart:ui';

import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/material.dart';

class CustomColor {
  Color textColor = controller.isDarkMode ? Colors.white : Colors.black;
  Color iconColor = controller.isDarkMode ? Colors.white : Colors.black;
  static Color themeColor = Color.fromRGBO(11, 139, 131, 1);

  // static Color themeColor = Color.fromRGBO(18, 208, 132, 1);
  static Color white = Colors.white;
  static Color grey = Color.fromRGBO(47,79,79,1);
  static Color pinkLight = Color.fromRGBO(228, 64, 141, 1);

  Color tabbarColor = controller.isDarkMode ? themeColor : white;
  Color chatRowColor =
      controller.isDarkMode ? themeColor : Color.fromRGBO(137, 222, 179, 1);

  Color themeTransparent =
      controller.isDarkMode ? Colors.transparent : themeColor;
}

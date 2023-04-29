import 'package:firebase_chat_demo/Screen/Login/NewLoginScreen.dart';
import 'package:firebase_chat_demo/Screen/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screen/ChatDetails/ChatDetailsFunction.dart';
import '../Screen/SettingScreen/SettingScreen.dart';
import '../Storage.dart';
import '../constant/ColorConstant.dart';

void handleClick(String value) {
  switch (value) {
    case 'Logout':
      {
        MyPrefs.removeUserId();
        Get.offAll(() => LoginScreen());
      }
      break;
    case 'Profile':
      Get.to(() => Profile());
      break;
    case 'Settings':
      Get.to(() => SettingScreen());
      break;
  }
}

class AppBarView extends StatelessWidget with PreferredSizeWidget {
  String? title;
  Color? backgroundColor = CustomColor.themeColor;
  Widget? AppBarActions;
  Widget? CustomWidget;

  AppBarView(
      {this.title,
      this.backgroundColor,
      this.AppBarActions,
      this.CustomWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: new Text(title!),
      backgroundColor: backgroundColor,
      actions: [
        if (CustomWidget != null) CustomWidget!,
        if (AppBarActions != null) AppBarActions!,
        if (AppBarActions == null)
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings', 'Profile'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class FloatingButtonView extends StatelessWidget with PreferredSizeWidget {
  FloatingButtonView({this.onPress, this.icon});

  Function()? onPress;
  IconData? icon;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPress,
      child: new Icon(icon, color: CustomColor.white),
    );
  }
}

class AppbarnoAction extends StatelessWidget with PreferredSizeWidget{
  AppbarnoAction();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: UserProfileImage,
      backgroundColor: CustomColor().themeTransparent,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

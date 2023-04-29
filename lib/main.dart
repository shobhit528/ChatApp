// @dart=2.9

import 'dart:io';

import 'package:firebase_chat_demo/ControllerClass.dart';
import 'package:firebase_chat_demo/Screen/Splash.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/bloc/dummy.dart';
import 'package:firebase_chat_demo/service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'Component/Pager.dart';
import 'Screen/Login/NewLoginScreen.dart';
import 'ThemeConfig.dart';
import 'constant/ColorConstant.dart';
import 'constant/appConstant.dart';

final Controller controller = new Controller();
final stateVariable = GetIt.instance.get<StateVariable>();
final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "flutter_background example app",
  notificationText:
      "Background notification for keeping the example app running in the background",
  notificationImportance: AndroidNotificationImportance.Max,
  notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable'), // Default is ic_launcher from folder mipmap
);

main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  Brightness appBrightness =
      SchedulerBinding.instance.window.platformBrightness;
  controller.DarkMode(appBrightness == Brightness.dark);
  //Background Manager
  if (Platform.isAndroid)
    FlutterBackground.initialize(androidConfig: androidConfig);
  controller.Appinformation();
  runApp(MultiProvider(
      providers: [
        // ChangeNotifierProvider.value(value: DBRef()),
        ChangeNotifierProvider.value(value: StateVariable()),
        ChangeNotifierProvider.value(value: UserColor()),
        ChangeNotifierProvider.value(value: AppConst()),
      ],
      child: MaterialApp(
        navigatorKey: Get.key,
        navigatorObservers: [GetObserver()],
        theme: controller.DarkMode.value
            ? ThemeData.dark()
            : CustomTheme.lightTheme,
        title: 'Flutter Database Example',
        home: Stack(
          alignment: Alignment.center,
          children: [
            Splash(),
            Obx(() => controller.Loader.value
                ? Positioned(
                    child: CircularProgressIndicator(
                        color: CustomColor.themeColor))
                : Container()),
          ],
        ),
      )));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        child: controller.stateVariable.userId == 0
            ? LoginScreen()
            : PagerWidget(),
      ),
    ));
  }
}

InitFirebaseDatabase() async {
  try {
    return await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyDBTxqTTzgbD-s_hfCsE6wNV0luaGlzGUk',
      appId: '1:701306233705:android:d8327880921319d6a9d3f8',
      messagingSenderId: '701306233705',
      projectId: 'demochatappflutter-c5e29',
      storageBucket: "gs://demochatappflutter-c5e29.appspot.com/",
      databaseURL:
          'https://demochatappflutter-c5e29-default-rtdb.firebaseio.com/',
    ));
  } catch (er) {
    return await Firebase.app();
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:firebase_chat_demo/bloc/dummy.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateSplash();
}

class StateSplash extends State<Splash> {
  @override
  void initState() {
    controller.databaseRef.initValues();
    super.initState();
    Timer(Duration(seconds: 3), () {
      Get.offAll(() => MyApp());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Image.asset(
            'assets/background3.jpg',
            height: Get.height,
            width: Get.width,
            fit: BoxFit.cover,
          ),
          new Center(
            child: new ClipRect(
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: new Container(
                  width: Get.width,
                  height: Get.height,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey.shade50.withOpacity(0.1)),
                  child: Center(
                      child: Image.asset(
                    'assets/appicon.jpg',
                    height: Get.width / 1.5,
                    width: Get.width / 1.5,
                  )),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedFillerButton extends StatefulWidget {
  AnimatedFillerButton({this.callback});

  Function? callback;

  @override
  AnimatedFillerButtonState createState() =>
      AnimatedFillerButtonState(callback);
}

class AnimatedFillerButtonState extends State<AnimatedFillerButton>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  RxInt count = 0.obs;

  AnimatedFillerButtonState(this.callback);

  Function? callback;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 30));
    super.initState();
    try {
      callback!(controller);
      Future(() {
        controller!.addListener(() {
          count(controller!.lastElapsedDuration!.inSeconds);
        });
      }).then((value) {
        controller!.forward();
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller!.reset(),
      // onTapDown: (_) => controller!.forward(),
      // onTapUp: (_) {
      //   if (controller!.status == AnimationStatus.forward) {
      //     controller!.reverse();
      //   }
      // },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: 30.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
          CircularProgressIndicator(
            value: controller!.value,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Obx(() => TextViewNew(count.toString()))
        ],
      ),
    );
  }
}

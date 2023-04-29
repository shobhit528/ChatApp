import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:provider/provider.dart';

import '../constant/appConstant.dart';
import '../main.dart';
import 'TextView.dart';

class PagerComponent extends StatelessWidget {
  RxInt currentIndex = 0.obs;
  PageController pageController = PageController();
  Function(int)? indexListener;

  PagerComponent({this.list, this.indexListener});

  List<Widget>? list = [];

  @override
  Widget build(BuildContext context) {
    CreateQRTabHeader(int i) {
      switch (i) {
        case 0:
          return Provider.of<AppConst>(Get.context!).myQR;
        case 1:
          return Provider.of<AppConst>(Get.context!).scanQR;

        default:
          return Provider.of<AppConst>(Get.context!).myQR;
      }
    }
    return Column(children: [
      Obx(() => Row(
          children: [0, 1]
              .map<Widget>((e) => Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 5),
                      color: CustomColor().themeTransparent,
                      child: GestureDetector(
                        onTap: () => pageController.animateToPage(e,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInExpo),
                        child: Column(children: [
                          TextView(
                            label: CreateQRTabHeader(e),
                            color: currentIndex.value == e
                                ? Colors.white
                                : Colors.grey,
                          ),
                          Container(
                            height: 2,
                            width: 100,
                            color: currentIndex.value == e
                                ? Colors.white
                                : Colors.transparent,
                          )
                        ]),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ))
              .toList())),
      Expanded(
          child: PageView(
        controller: pageController,
        onPageChanged: (value) {
          currentIndex(value);
          indexListener!(value);
        },
        children: <Widget>[
          for (var e in list!) SizedBox(child: e)
          // KeepAlivePage(key: Key("%"), child: e),
        ],
      ))
    ]);
  }
}

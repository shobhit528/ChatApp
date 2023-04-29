import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../constant/ColorConstant.dart';
import 'TextView.dart';

class CustomButtonElevated extends StatelessWidget {
  RxBool isclick = false.obs;

  CustomButtonElevated({this.onPress, this.widget, this.buttontext});

  Function(bool)? onPress;
  Widget? widget;
  String? buttontext;

  @override
  Widget build(BuildContext context) => Obx(() => Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(5),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          decoration: BoxDecoration(
              color: isclick.value ? CustomColor.themeColor : Colors.red.shade300,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                isclick.value
                    ? BoxShadow(
                        color: isclick.value
                            ? Colors.blueGrey
                            : Colors.red.shade500,
                        offset: const Offset(4, 4),
                        blurRadius: 15,
                        spreadRadius: 1)
                    : const BoxShadow()
              ]),
          child: Stack(alignment: Alignment.center, children: [
            widget ??
                Padding(
                    padding: EdgeInsets.all(10),
                    child:
                        TextViewNew(buttontext!, color: CustomColor().textColor)),
            // isclick.value
            //     ? SizedBox(
            //         child: CircularProgressIndicator(),
            //         height: 20,
            //         width: 20,
            //       )
            //     : SizedBox()
          ]),
        ),
        onTap: () => {isclick(!isclick.value), onPress!(isclick.value)},
      )));
}

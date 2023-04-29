import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Component/MapScreen.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../../constant/ColorConstant.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';

import '../../constant/appConstant.dart';

class ShareLocation extends View<FirebaseDataModal> {
  ShareLocation({this.liveLocation, this.onResult})
      : super(FirebaseDataModal());
  bool? liveLocation = false;
  Null Function(dynamic res)? onResult;
  int? index;
  TextEditingController inputController = new TextEditingController();
  double? height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(title: "Share Your Location"),
      body: SafeArea(
        child: Container(
            margin: EdgeInsets.all(5),
            child: ListView(
              children: [
                SizedBox(
                  child: MapScreen(),
                  height: liveLocation != null ? 500 : 200,
                ),

                //for Location Sharing Screening
                if (liveLocation == null)
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaddedWidget(
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Icon(Icons.location_on),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: CustomColor.themeColor),
                                    ),
                                    flex: 1,
                                  ),
                                  Flexible(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Expanded(
                                      child: TextViewNew(
                                        Provider.of<AppConst>(context).shareLocation,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                      flex: 5),
                                ],
                              ),
                              () => Get.to(() => ShareLocation(
                                  liveLocation: true, onResult: onResult))),
                          PaddedWidget(Divider(
                            height: 1,
                            thickness: 1,
                          )),
                          PaddedWidget(TextViewNew(
                            Provider.of<AppConst>(context).nearby,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          )),
                          PaddedWidget(
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Icon(Icons.adjust_rounded),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 0.5, color: CustomColor.themeColor)),
                                    ),
                                    flex: 1,
                                  ),
                                  Flexible(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Expanded(
                                    child: TextViewNew(
                                      Provider.of<AppConst>(context).sendLocation,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    flex: 5,
                                  ),
                                ],
                              ),
                              () => getCurrentLocation(
                                  (location) => onResult!(location))),
                        ],
                      )),

                //for Live Location Screening
                if (liveLocation != null)
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaddedWidget(
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                      child: TextViewNew(
                                        Provider.of<AppConst>(context).shareLocation,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                      ),
                                      flex: 5),
                                ],
                              ),
                              () => Get.to(() => ShareLocation(
                                  liveLocation: true, onResult: (res)=>onResult!(res)))),
                          PaddedWidget(new Card(
                            child: Row(children: [
                              CardText(
                                  name: "15 Minutes",
                                  isSelected: index == 0,
                                  onTap: () {
                                    setState(() {
                                      if (index == 0)
                                        index = null;
                                      else
                                        index = 0;
                                    });
                                  }),
                              CardText(
                                  name: "1 Hour",
                                  isSelected: index == 1,
                                  onTap: () {
                                    setState(() {
                                      if (index == 1)
                                        index = null;
                                      else
                                        index = 1;
                                    });
                                  }),
                              CardText(
                                  name: "8 Hours",
                                  isSelected: index == 2,
                                  onTap: () {
                                    setState(() {
                                      if (index == 2)
                                        index = null;
                                      else
                                        index = 2;
                                    });
                                  }),
                            ]),
                          )),
                          PaddedWidget(Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          color: controller.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          border: Border.all(width: 1),
                                          shape: BoxShape.rectangle),
                                      child: TextFormField(
                                        controller: inputController,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 1,
                                        maxLines: 5,
                                        textAlign: TextAlign.start,
                                        decoration: new InputDecoration(
                                          labelStyle: TextStyle(
                                              color: controller.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white),
                                          hintText: Provider.of<AppConst>(context).comment,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 5),
                                        ),
                                      ))),
                              GestureDetector(
                                  child: Icon(Icons.send),
                                  onTap: () async {
                                    // onResult();
                                    int count = index == 0
                                        ? 900
                                        : index == 1
                                            ? 3600
                                            : index == 2
                                                ? 28800
                                                : 0;
                                    Map map = new Map();
                                    map["timeCount"] = count;
                                    map["liveLocation"]=true;
                                    map["comment"] = inputController.value.text
                                        .toString()
                                        .trim();
                                    map.removeWhere((key, value) =>
                                        key == null || value == null);
                                    onResult!(map);
                                  })
                            ],
                          ))
                        ],
                      ))
              ],
            )),
      ),
    );
  }
}

Widget PaddedWidget(widget, [Function()? onPress]) {
  return GestureDetector(
    onTap: onPress,
    behavior: HitTestBehavior.translucent,
    child: Padding(padding: EdgeInsets.symmetric(vertical: 5), child: widget),
  );
}

Widget CardText({name, bool isSelected = false, Function()? onTap}) {
  return Expanded(
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: new Card(
              color: isSelected ? CustomColor.themeColor : Colors.grey,
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: TextViewNew(name),
              ))),
      flex: 1);
}

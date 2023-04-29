import 'package:firebase_chat_demo/Component/MapScreen.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Screen/ChatDetails/VideoCallingScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Utils/utils.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/appConstant.dart';
import '../../main.dart';

Dater(s) {
  try {
    DateFormat inputFormat = DateFormat('yy-MM-DD hh:mm:ssZ');
    return controller.FormateTime(inputFormat.parse(s));
  } catch (e) {
    return s;
  }
}

final chatDecoration = ({bool isSender = true}) => BoxDecoration(
      color: isSender
          ? CustomColor().chatRowColor.withOpacity(0.8)
          : Colors.blueGrey.withOpacity(0.8),
      borderRadius: isSender
          ? BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              topLeft: Radius.circular(10.0))
          : BorderRadius.only(
              bottomRight: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              topLeft: Radius.circular(10.0)),
    );

final UserProfileImage = new GestureDetector(
  onTap: () {},
  behavior: HitTestBehavior.translucent,
  child: Container(
      width: 30.0,
      height: 30.0,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.fill,
              image: new NetworkImage(
                  "https://png.pngtree.com/png-clipart/20190924/original/pngtree-user-vector-avatar-png-image_4830521.jpg")))),
);

final UserInputField = ({inputController, onChange}) => new Expanded(
    child: Container(
        constraints: BoxConstraints(minHeight: 100, maxHeight: Get.height / 5),
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: controller.isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border: Border.all(width: 1),
            shape: BoxShape.rectangle),
        child: TextFormField(
          controller: inputController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          textAlign: TextAlign.start,
          onChanged: onChange,
          decoration: new InputDecoration(
            labelStyle: TextStyle(
                color: controller.isDarkMode ? Colors.black : Colors.white),
            hintText: 'Type your message here...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
          ),
        )));

final LiveLocationWidget = ({senderId}) => Container(
      padding: EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 5),
      child: Stack(
        children: [
          SizedBox(
            // child: new MapScreen(),
            child: Image.asset('assets/mapLive.png'),
            height: 200,
            width: 200,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Get.to(() => new MapScreen(senderId)),
            child: Container(
              height: 200,
              width: 200,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );

final ChatTimeWidget = ({bool? condition, String? time, Color? color}) =>
    Padding(
      padding:
          EdgeInsets.only(right: condition! ? 50 : 0, left: condition ? 0 : 50),
      child: TextView(
        label: Dater(time) ?? "",
        type: 1,
        fontSize: 12,
        color: color,
      ),
    );

var LiveLocationTextSenderWidget =
    ({bool? condition, onPress}) => GestureDetector(
          child: Padding(
            child: TextViewNew(
              condition!
                  ? Provider.of<AppConst>(Get.context!).sharingEnded
                  : Provider.of<AppConst>(Get.context!).sharingStop,
              color: condition ? CustomColor.white : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: condition ? () {} : onPress,
        );

var LiveLocationTextReceiverWidget =
    ({senderId, bool? condition}) => GestureDetector(
          child: Padding(
            child: TextViewNew(
              condition!
                  ? Provider.of<AppConst>(Get.context!).sharingEnded
                  : Provider.of<AppConst>(Get.context!).activlyLocation,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () => Get.to(() => new MapScreen(senderId)),
        );

var musicWidget = ({String? url, String? name}) => GestureDetector(
    onTap: () => UrlLauncher(url),
    behavior: HitTestBehavior.translucent,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.library_music, size: 20),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Text(
                  name!,
                  style: TextStyle(color: CustomColor.white),
                  textWidthBasis: TextWidthBasis.longestLine,
                  maxLines: 2,
                ))),
      ],
    ));

var documentWidget = ({String? url, String? name}) => GestureDetector(
    onTap: () => UrlLauncher(url),
    behavior: HitTestBehavior.translucent,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.note, size: 20),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Text(
                  name!,
                  style: TextStyle(color: CustomColor.white),
                ))),
      ],
    ));

Widget ContactWidget(
        {String? name, String? number, onPress, bool? isAvailable}) =>
    GestureDetector(
      onTap: () {
        if (isAvailable!) {
          DatabaseFunction().InitChatListMessage(
              name: name, receiverNumber: int.parse(number!));
        } else {
          String url =
              "sms:$number?body=Let's chat on ${AppConst.AppName}! It's simple, fast and secure app. we can use to message each and call(coming soon).";
          UrlLauncher(url);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child:
                          Icon(Icons.quick_contacts_dialer_outlined, size: 40)),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: TextViewNew(
                    name! + ".vcf",
                    fontWeight: FontWeight.bold,
                    color: CustomColor.white,
                  )),
                  // TextViewNew(number!),
                ],
                mainAxisSize: MainAxisSize.min),
            SizedBox(
              width: 150,
              child: Divider(thickness: 1),
            ),
            TextView(
              label: isAvailable! ? "Message" : "Invite",
              type: 1,
              fontWeight: FontWeight.bold,
              color: CustomColor.grey,
            )
          ], mainAxisSize: MainAxisSize.min)),
    );

Widget CallingWidget(
        {data, bool? isSender, CallerId, Function(dynamic)? callback}) =>
    GestureDetector(
      onTap: data["action"] == "endCalling"
          ? () {}
          : () => Get.to(() => VideoCallingApp(
                uid: data["uid"],
                isCallAudio: data["type"] == "Audio Call",
                CallerId: CallerId,
                callback: callback,
              )),
      child: Container(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: Icon(
                          data["type"] == "Audio Call"
                              ? Icons.call_rounded
                              : Icons.video_call,
                          size: 30)),
                  SizedBox(
                    width: 10,
                  ),
                  TextViewNew(
                    "You started a ${data["users"].length == 2 ? "" : "group"} \n ${data["type"]}",
                    fontWeight: FontWeight.bold,
                    color: CustomColor.white,
                  ),
                ],
                mainAxisSize: MainAxisSize.min)),
      ),
      behavior: HitTestBehavior.translucent,
    );

import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Screen/SettingScreen/Account.dart';
import 'package:firebase_chat_demo/Screen/SettingScreen/Help.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Component/CircularImageView.dart';
import '../../Component/TextView.dart';
import '../../constant/ColorConstant.dart';
import 'Chats.dart';
import 'QRScreen.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(title: "Setting Screen"),
      body: SafeArea(
          child: Stack(
        alignment: Alignment.center,
        children: [
          CustomScrollView(
            controller: ScrollController(initialScrollOffset: 0),
            slivers: [
              // SliverAppBar(
              //   title: Text("Setting Screen"),
              //   pinned: true,
              //   flexibleSpace: Image.network(
              //       "https://picsum.photos/${Get.width.round()}/300",
              //       cacheHeight: 300,
              //       cacheWidth: Get.width.round(),
              //       fit: BoxFit.cover),
              //   floating: true,
              //   expandedHeight: 300,
              // ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.white),
                                  shape: BoxShape.circle),
                              child: Obx(() => ImageViewCircle(
                                    url: controller.UserProfile.value["avatar"]??"",
                                    radiusSize: 30,
                                  )),
                            ),
                            flex: 1),
                        Expanded(
                            child: Obx(() => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextViewNew(
                                          controller.UserProfile.value["user"],
                                          fontSize: 18,
                                          textAlign: TextAlign.left),
                                      TextViewNew(controller
                                          .UserProfile.value["about"]??""),
                                    ])),
                            flex: 2),
                        Expanded(
                          child: GestureDetector(
                            child: Icon(
                              Icons.qr_code,
                              color: CustomColor.themeColor,
                              size: 30,
                            ),
                            onTap: () => Get.to(() => QRClass()),
                            behavior: HitTestBehavior.translucent,
                          ),
                          flex: 1,
                        )
                      ], crossAxisAlignment: CrossAxisAlignment.center)),
                  ListItem(icon: Icons.vpn_key, text: Provider.of<AppConst>(context).account),
                  ListItem(icon: Icons.chat_sharp, text: Provider.of<AppConst>(context).chats),
                  // ListItem(icon: Icons.notifications, text: "Notification"),
                  ListItem(icon: Icons.help, text: Provider.of<AppConst>(context).help),
                  // ListItem(icon: Icons.wc, text: "Invite a friend"),
                  Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: TextViewNew(Provider.of<AppConst>(context).fromCompany,
                        textAlign: TextAlign.center,
                      ))
                ]),
              ),
            ],
          ),
          Obx(() => controller.Loader.isTrue
              ? CircularProgressIndicator()
              : SizedBox())
        ],
      )),
    );
  }
}

final ListItem = ({String? text, IconData? icon}) => ListTile(
    title: TextViewNew(text!, fontSize: 18),
    onTap: () => ClickHandler(text),
    leading: Icon(
      icon,
      size: 18,
    ));

ClickHandler(String text) {
  switch (text) {
    case "Accounts":
      Get.to(() => Account());
      break;
    case "Chats":
      Get.to(() => Chats());
      break;
    case "Notification":
      break;
    case "Help":
      Get.to(() => Help());
      break;
    case "Invite a friend":
      break;
    default:
      break;
  }
}

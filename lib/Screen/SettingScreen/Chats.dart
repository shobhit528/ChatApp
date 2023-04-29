import 'dart:async';

import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:firebase_chat_demo/database/filemanager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../../Component/customElevatedButton.dart';
import '../../constant/appConstant.dart';
import '../../main.dart';

class Chats extends View<FirebaseDataModal> {
  late DatabaseReference messageRef = $.model.getValue(#MessageViewRef);
  late DatabaseReference chatlistRef = $.model.getValue(#ChatListRef);

  Chats() : super(FirebaseDataModal());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(title: Provider.of<AppConst>(context).chats),
        body:
            ListView(padding: EdgeInsets.symmetric(horizontal: 20), children: [
          Row(children: [
            Expanded(
                child: TextViewNew(Provider.of<AppConst>(context).backup,
                    color: CustomColor().textColor, fontSize: 16)),
            CustomButtonElevated(
              buttontext: Provider.of<AppConst>(context).backupData,
              onPress: (bool a) {
                controller.Loader(true);
                FileManager()
                    .writeJsontoFile(
                        messageRef: messageRef, chatRef: chatlistRef)
                    .then((value) => controller.Loader(false));
              },
            ),
          ]),
          Row(children: [
            Expanded(
                child: TextViewNew(Provider.of<AppConst>(context).restore,
                    color: CustomColor().textColor, fontSize: 16)),
            CustomButtonElevated(
                buttontext: Provider.of<AppConst>(context).restoreData,
                onPress: (bool a) async {
                  dynamic data = await FileManager().readJsonFile();
                  data["chatList"].forEach((value) {
                    unawaited(chatlistRef.push().set(value));
                  });
                }),
          ]),
        ]));
  }
}

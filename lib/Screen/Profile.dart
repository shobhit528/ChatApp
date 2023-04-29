import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../Modal/firebaseDataModal.dart';
import '../constant/ColorConstant.dart';

class Profile extends View<FirebaseDataModal> {
  Profile() : super(FirebaseDataModal());

  int? userId;

  @override
  void init(BuildContext context) {
    super.init(context);
    MyPrefs.getUserId().then((value) => userId = value);
    if (controller.UserProfile.value["about"] == null)
      controller.UserProfile.value["about"] = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(title: Provider.of<AppConst>(context).userProfile),
        body: $.watchFor<DatabaseReference>(#AccountDataRef,
            builder: $.builder1((accountData) => ListView(children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.white),
                            // borderRadius: BorderRadius.circular(60),
                            shape: BoxShape.circle),
                        child: Obx(() => CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                  controller.UserProfile.value["avatar"] ??
                                      AppConst.PlaceHolder,
                                  scale: 10),
                            )),
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () =>
                              Utils.showImagePicker(context, (image) async {
                            File imagefile =
                                File(image.path); //convert Path to File
                            Uint8List imagebytes =
                                await imagefile.readAsBytes();
                            FS.FirebaseStorage ref =
                                $.model.getValue(#FireStore);
                            await imagefile.writeAsBytes(imagebytes.buffer
                                .asUint8List(imagebytes.offsetInBytes,
                                    imagebytes.lengthInBytes));
                            FS.Reference previousAvatarRef =
                                await ref.refFromURL(
                                    controller.UserProfile.value["avatar"]);
                            FS.TaskSnapshot snapshot = await ref
                                .ref()
                                .child("images/${DateTime.now()}")
                                .putFile(imagefile);
                            if (snapshot.state == FS.TaskState.success) {
                              final String downloadUrl =
                                  await snapshot.ref.getDownloadURL();
                              previousAvatarRef.delete().then((value) {
                                accountData
                                    .child("$userId")
                                    .update({"avatar": downloadUrl});
                                setState(() {});
                              });
                            }
                          }),
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            decoration: BoxDecoration(
                                color: CustomColor.themeColor,
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.camera_enhance,
                              color: Colors.white,
                              size: 25,
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                        bottom: 10,
                        right: 10,
                      )
                    ]),
                  ),
                  Obx(() => ProfileRow(
                      icon: Icons.account_circle,
                      title: Provider.of<AppConst>(context).name,
                      content: controller.UserProfile.value["user"],
                      callback: (bool status) {
                        if (status) {
                          accountData.child("$userId").update(
                              {"user": controller.UserProfile.value["user"]});
                          setState(() {});
                          Get.back();
                        }
                      })),
                  Obx(() => ProfileRow(
                      icon: Icons.info_outline,
                      title: Provider.of<AppConst>(context).about,
                      content: controller.UserProfile.value["about"] ??
                          "".toString(),
                      callback: (bool status) {
                        if (status) {
                          accountData.child("$userId").update(
                              {"about": controller.UserProfile.value["about"]});
                          setState(() {});
                          Get.back();
                        }
                      })),
                  Obx(() => ProfileRow(
                        icon: Icons.add_call,
                        title: Provider.of<AppConst>(context).number,
                        content: controller.UserProfile.value["number"],
                        editable: false,
                      ))
                ]))));
  }
}

Widget ProfileRow(
    {IconData? icon,
    String title = "",
    String content = "",
    editable: true,
    Function(bool)? callback}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Expanded(
          child: Icon(
            icon,
            color: CustomColor().iconColor,
            size: 25,
          ),
          flex: 1),
      Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextViewNew(
                title,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              TextViewNew(
                content,
                fontSize: 20,
              )
            ]),
        flex: 3,
      ),
      Expanded(
          child: editable
              ? GestureDetector(
                  onTap: () =>
                      BottomInputField(field: title, needUpdate: callback),
                  child: Icon(Icons.edit, color: CustomColor().iconColor))
              : SizedBox(),
          flex: 1),
    ]),
  );
}

Future<dynamic> BottomInputField({String? field, Function(bool)? needUpdate}) {
  final TextEditingController editingController = new TextEditingController();
  return showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TextViewNew(
                    Provider.of<AppConst>(Get.context!).enterField(field!),
                    color: CustomColor().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextField(
                    decoration: InputDecoration(hintText: field),
                    autofocus: false,
                    controller: editingController,
                  ),
                ),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                      onPressed: () {
                        controller.UserProfile
                                .value[field == "About" ? "about" : "user"] =
                            editingController.value.text;
                        needUpdate!(true);
                      },
                      style: ButtonStyle(
                          alignment: Alignment.center,
                          animationDuration: Duration(seconds: 1)),
                      child: TextViewNew(
                        Provider.of<AppConst>(context).save,
                        fontSize: 18,
                        color: CustomColor().textColor,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        needUpdate!(false);
                        Get.back();
                      },
                      style: ButtonStyle(
                          alignment: Alignment.center,
                          animationDuration: Duration(seconds: 1)),
                      child: TextViewNew(
                        Provider.of<AppConst>(context).cancel,
                        fontSize: 18,
                        color: CustomColor().textColor,
                      ))
                ]),
              ],
            ),
          ));
}

import 'dart:io';

import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';

import '../../Component/EditText.dart';
import '../../Component/Pager.dart';
import '../../Storage.dart';

class Signup extends View<FirebaseDataModal> {
  Signup() : super(FirebaseDataModal());
  Map data = {}.obs;

  // AccountDataRef
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Login'),
      ),
      body: $.watchFor<DatabaseReference>(#AccountDataRef,
          builder: $.builder1(
            (Accounts) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Stack(children: [
                    Obx(() => Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              shape: BoxShape.circle),
                          child: GestureDetector(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: data["image"] != null
                                    ? Image.file(
                                        File(data["image"]),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.fill,
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(
                                            "https://picsum.photos/500",
                                            scale: 10),
                                      )),
                            onTap: () {},
                          ),
                        )),
                    Positioned(
                      child: Icon(Icons.camera_alt,
                          color: Colors.blueAccent, size: 40),
                      bottom: 0,
                    )
                  ]),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Utils.showImagePicker(context, (image) {
                      data["image"] = image.path;
                    });
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                InputTextView(
                  labelText: "Name",
                  onChange: (value) => data["name"] = value,
                ),
                InputTextView(
                  labelText: "Number",
                  type: "number",
                  onChange: (value) => data["number"] = value,
                ),
                InputTextView(
                  labelText: "IPIN",
                  type: "number",
                  secureText: true,
                  onChange: (value) => data["password"] = value,
                ),
                OutlinedButton(
                    onPressed: () {
                      Accounts.update({
                        data["number"]: {
                          "number": data["number"],
                          "user": data["name"],
                          "image": data["image"],
                          "password": data["password"]
                        }
                      });
                      MyPrefs.setUserId(int.parse(data["number"]));
                      Get.offAll(() => PagerWidget());
                    },
                    style: ButtonStyle(alignment: Alignment.center),
                    child: Text("Save Account"))
              ],
            ),
          )),
    );
  }
}

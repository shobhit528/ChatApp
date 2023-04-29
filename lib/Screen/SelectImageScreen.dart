import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';

import '../Component/EditText.dart';
import '../constant/ColorConstant.dart';
import '../main.dart';

class SelectionScreen extends View<FirebaseDataModal> {
  SelectionScreen({this.imagePath}) : super(FirebaseDataModal());
  late String? imagePath;
  var caption;
  late int userId = $.model.getValue(#userID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Send Image"),
        leading: IconButton(
            onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_sharp)),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     File imagefile = File(imagePath!); //convert Path to File
      //     Uint8List imagebytes = await imagefile.readAsBytes();
      //     FS.FirebaseStorage ref = $.model.getValue(#FireStore);
      //     await imagefile.writeAsBytes(imagebytes.buffer
      //         .asUint8List(imagebytes.offsetInBytes, imagebytes.lengthInBytes));
      //     FS.TaskSnapshot snapshot = await ref
      //         .ref()
      //         .child("images/${DateTime.now()}")
      //         .putFile(imagefile);
      //     if (snapshot.state == FS.TaskState.success) {
      //       final String downloadUrl = await snapshot.ref.getDownloadURL();
      //       Map<String, dynamic> data = {
      //         "time": DateTime.now().toString(),
      //         "content": downloadUrl,
      //         "caption": caption,
      //         "type": "image"
      //       };
      //       DatabaseReference databaseReference =
      //           $.model.getValue(#StatusListRef);
      //       databaseReference
      //           .child("$userId")
      //           .push()
      //           .set(data)
      //           .then((value) => Get.offAll(() => HomeScreen()));
      //     }
      //   },
      //   child: Icon(Icons.send),
      // ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(""),
                  Expanded(
                      child: Container(
                    child: imagePath == null
                        ? Image.network("https://picsum.photos/500")
                        : Image.file(File(imagePath!)),
                    margin: EdgeInsets.all(10),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: InputTextView(
                          labelText: "Caption",
                          onChange: (value) => caption = value.trim(),
                        ),
                        flex: 1,
                      ),
                      GestureDetector(
                        onTap: () async {
                          controller.Loader(true);
                          File imagefile =
                              File(imagePath!); //convert Path to File
                          Uint8List imagebytes = await imagefile.readAsBytes();
                          FS.FirebaseStorage ref = $.model.getValue(#FireStore);
                          await imagefile.writeAsBytes(imagebytes.buffer
                              .asUint8List(imagebytes.offsetInBytes,
                                  imagebytes.lengthInBytes));
                          FS.TaskSnapshot snapshot = await ref
                              .ref()
                              .child("images/${DateTime.now()}")
                              .putFile(imagefile);
                          if (snapshot.state == FS.TaskState.success) {
                            final String downloadUrl =
                                await snapshot.ref.getDownloadURL();
                            Map<String, dynamic> data = {
                              "time": DateTime.now().toString(),
                              "content": downloadUrl,
                              "caption": caption,
                              "type": "image"
                            };
                            DatabaseReference databaseReference =
                                $.model.getValue(#StatusListRef);
                            databaseReference
                                .child("$userId")
                                .push()
                                .set(data)
                                .then((value) {
                              controller.Loader(false);
                              // Get.offAll(() => PagerWidget(selectedIndex: 1));
                              Get.back(result: true);
                            });
                          } else {
                            controller.Loader(false);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: CustomColor.themeColor,
                              shape: BoxShape.circle),
                          child: Icon(Icons.send),
                        ),
                      )
                    ],
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(right: 80),
                  //   child: InputTextView(
                  //     labelText: "Caption",
                  //     onChange: (value) => caption = value.trim(),
                  //   ),
                  // )
                ]),
          ),
          Obx(() => controller.Loader.value
              ? CircularProgressIndicator()
              : Container())
        ],
      ),
    );
  }
}

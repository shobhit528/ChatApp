import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat_demo/Component/Pager.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../../Component/Pager.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/appConstant.dart';

class ProfileInfoScreen extends View<FirebaseDataModal> {
  ProfileInfoScreen() : super(FirebaseDataModal());

  bool isLoading = false;
  final TextEditingController CodeController = new TextEditingController();
  late DatabaseReference accountRef =
      $.model.getValue<DatabaseReference>(#AccountDataRef);
  late int userId = $.model.getValue<int>(#userID);
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextViewNew(Provider.of<AppConst>(context).profileInfo,
              fontWeight: FontWeight.bold, fontSize: 20),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextViewNew(
                          Provider.of<AppConst>(context).provideInfo,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.white),
                                  // borderRadius: BorderRadius.circular(60),
                                  shape: BoxShape.circle),
                              child: imageUrl == null
                                  ? Container(
                                      height: 120,
                                      width: 120,
                                      clipBehavior: Clip.antiAlias,
                                      decoration:
                                          BoxDecoration(shape: BoxShape.circle),
                                      child: Image.asset(
                                        'assets/placeholder.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(imageUrl!, scale: 10),
                                    ),
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: () => ImageSelectionProcess(),
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
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Input(
                              controller: CodeController,
                              hint: Provider.of<AppConst>(context).yourName,
                              padding: EdgeInsets.only()),
                        ),
                      ]),
                  OutlinedButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus!.unfocus();

                        if (CodeController.value.text.isEmpty) {
                          Get.snackbar(
                              "invalid value", Provider.of<AppConst>(context).enterName);
                        } else {
                          NavigateToUserProfileUpdate();
                        }
                      },
                      style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor:
                              MaterialStateProperty.all(CustomColor.themeColor),
                          animationDuration: Duration(seconds: 1)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        TextViewNew(
                          Provider.of<AppConst>(context).next.toUpperCase(),
                          textAlign: TextAlign.center,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ])),
                ]),
            if (isLoading) CircularProgressIndicator()
          ],
        ));
  }

  NavigateToUserProfileUpdate() {
    setState(() {
      isLoading = true;
    });
    accountRef.child("$userId").update({
      "user": CodeController.value.text.trimRight(),
      "avatar": imageUrl ?? "https://picsum.photos/id/237/200/300",
      "about": "",
      "isRegistered": true
    }).then((value) {
      setState(() {
        isLoading = false;
      });
      Get.offAll(() => PagerWidget());
    });
  }

  ImageSelectionProcess() {
    Utils.showImagePicker(Get.context, (image) async {
      setState(() {
        isLoading = true;
      });
      late FS.Reference previousAvatarRef;
      File imagefile = File(image.path);
      Uint8List imagebytes = await imagefile.readAsBytes();
      FS.FirebaseStorage ref = $.model.getValue(#FireStore);
      await imagefile.writeAsBytes(imagebytes.buffer
          .asUint8List(imagebytes.offsetInBytes, imagebytes.lengthInBytes));
      if (imageUrl != null) previousAvatarRef = await ref.refFromURL(imageUrl!);
      FS.TaskSnapshot snapshot =
          await ref.ref().child("images/${DateTime.now()}").putFile(imagefile);
      if (snapshot.state == FS.TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        try {
          if (previousAvatarRef != null) {
            previousAvatarRef.delete().then((value) {
              setState(() {
                imageUrl = downloadUrl;
                isLoading = false;
              });
            });
          } else
            setState(() {
              imageUrl = downloadUrl;
              isLoading = false;
            });
        } catch (e) {
          setState(() {
            imageUrl = downloadUrl;
            isLoading = false;
          });
        }
      }
    });
  }
}

Widget Input(
    {String? hint,
    maxLength = null,
    TextEditingController? controller,
    Function(String)? onChange,
    padding = const EdgeInsets.only(left: 15)}) {
  return TextFormField(
    keyboardType: TextInputType.name,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.singleLineFormatter
    ],
    // Only numbers can be ent
    controller: controller,
    maxLength: maxLength,
    onChanged: onChange,
    decoration: InputDecoration(
        hintText: hint,
        alignLabelWithHint: true,
        counterText: "",
        contentPadding: padding),
  );
}

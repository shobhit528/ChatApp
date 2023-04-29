import 'dart:async';

import 'package:firebase_chat_demo/ControllerClass.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';
import 'package:status_view/status_view.dart';

import '../Modal/firebaseDataModal.dart';
import '../constant/ColorConstant.dart';
import '../constant/appConstant.dart';
import 'SelectImageScreen.dart';
import 'StatusViewer.dart';

Controller AppController = new Controller();

class StatusScreen extends View<FirebaseDataModal> {
  StatusScreen() : super(FirebaseDataModal());
  late int userId = $.model.getValue(#userID);

  late DatabaseReference StatusRef =
      $.model.getValue<DatabaseReference>(#StatusListRef);
  late FS.FirebaseStorage ref =
      $.model.getValue<FS.FirebaseStorage>(#FireStore);
  List arr = [];
  bool StoryLabel = false;

  @override
  void init(BuildContext context) {
    MyPrefs.getUserId().then((value) {
      userId = value!;
    });

    super.init(context);
    try {
      Timer(Duration(seconds: 3), () {
        if (StatusRef != null)
          unawaited(StatusRef.get().then((DataSnapshot value) {
            if (value.value != null)
              value.value.forEach((keys, values) {
                try {
                  Map<String, dynamic> data =
                      new Map<String, dynamic>.from(values);

                  if (data.length == 0) {
                    arr.add({"Parentkey": keys});
                  }
                  data.forEach((key, values) {
                    int value = DateTime.now()
                        .difference(DateTime.parse(values["time"]))
                        .inSeconds;
                    int h = value ~/ 3600;
                    int m = ((value - h * 3600)) ~/ 60;

                    if (h > 24) {
                      arr.add({
                        "childkey": key,
                        "url": values["content"],
                        "Parentkey": keys
                      });
                    } else if (h == 23 && m >= 59) {
                      arr.add({
                        "childkey": key,
                        "url": values["content"],
                        "Parentkey": keys
                      });
                    }
                  });
                } catch (e) {}
              });
          }).then((value) => DeleteCloudData(StatusRef, ref)));
      });
    } catch (e) {}
  }

  DeleteCloudData(DatabaseReference StatusDelete, imageDelete) {
    arr.forEach((e) {
      unawaited(imageDelete.refFromURL(e["url"]).delete());
      unawaited(
          StatusDelete.child(e["Parentkey"]).child(e["childkey"]).remove());
    });
    try {
      setState(() {});
    } catch (e) {}
  }

  Future<void> ImageRemove(url) async {
    return await ref.refFromURL(url).delete();
  }

  Future<void> ChildRemove(key) async {
    return await StatusRef.child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: $.watchFor<DatabaseReference>(#StatusListRef,
                builder: $.builder1((StatusListing) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (StatusListing != null) MyStatusWidget(),
                        if (StoryLabel)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              Provider.of<AppConst>(context).stories,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        if (StatusListing != null)
                          Flexible(
                            child: FirebaseAnimatedList(
                              query: StatusListing,
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                if (snapshot.key == userId.toString()) {
                                  return SizedBox();
                                } else {
                                  StoryLabel = true;
                                  return SizeTransition(
                                      sizeFactor: animation,
                                      child: ChatRow(snapshot, StatusListing));
                                }
                              },
                            ),
                          ),
                      ],
                    ))),
            floatingActionButton: FloatingActionButton(
              backgroundColor: CustomColor.themeColor,
              onPressed: () async {
                Utils.showImagePicker(Get.context, (callbackRes) async {
                  if (callbackRes.path != null) {
                    final result = await Get.to(() => SelectionScreen(
                          imagePath: callbackRes.path,
                        ));
                    if (result != null) setState(() {});
                  }
                });
              },
              tooltip: 'Status',
              child: new Icon(
                Icons.camera_alt,
                color: CustomColor.white,
                size: 30,
              ),
            )));
  }

  MyStatusRow([snapshot]) {
    try {
      Map<String, dynamic> data = new Map<String, dynamic>.from(snapshot);
      return GestureDetector(
        onTap: () {
          try {
            List Arr = [];
            data.values.forEach((element) {
              Arr.add(element);
            });
            Get.to(() => StatusViewer(items: Arr));
          } catch (e) {}
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: StatusView(
                          radius: 25,
                          spacing: 15,
                          strokeWidth: 2,
                          indexOfSeenStatus: 0,
                          numberOfStatus: data.length,
                          padding: 4,
                          centerImageUrl: "https://picsum.photos/200/300",
                          seenColor: Colors.grey,
                          unSeenColor: Colors.red,
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Provider.of<AppConst>(Get.context!).myStatus,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Provider.of<AppConst>(Get.context!).addStatus,
                            ),
                          ],
                        ),
                        flex: 3,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                )
              ],
            )),
      );
    } catch (e) {
      return GestureDetector(
        onTap: () {
          Utils.showImagePicker(Get.context, (callbackRes) async {
            if (callbackRes.path != null)
              Get.to(() => SelectionScreen(
                    imagePath: callbackRes.path,
                  ));
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.centerLeft,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: StatusView(
                              radius: 30,
                              spacing: 15,
                              strokeWidth: 2,
                              indexOfSeenStatus: 0,
                              numberOfStatus: 1,
                              padding: 4,
                              centerImageUrl: "https://picsum.photos/200/300",
                              seenColor: Colors.transparent,
                              unSeenColor: Colors.transparent,
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Provider.of<AppConst>(Get.context!).myStatus,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  Provider.of<AppConst>(Get.context!).addStatus,
                                ),
                              ],
                            ),
                            flex: 3,
                          ),
                        ],
                      ),
                      Positioned(
                          child: Container(
                            decoration: BoxDecoration(
                                color: CustomColor.themeColor,
                                shape: BoxShape.circle,
                                border: Border.all(width: 0.5)),
                            child: Icon(Icons.add),
                          ),
                          left: 50,
                          bottom: 0)
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                )
              ],
            )),
      );
    }
  }

  ChatRow(DataSnapshot snapshot, DatabaseReference StatusListing) {
    // bool thisUser = snapshot.key == userId.toString();
    Map<String, dynamic> data = new Map<String, dynamic>.from(snapshot.value);
    if (snapshot.key != userId.toString())
      return GestureDetector(
        onTap: () {
          try {
            List Arr = [];
            data.values.forEach((element) {
              Arr.add(element);
            });
            Get.to(() => StatusViewer(items: Arr));
          } catch (e) {}
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: StatusView(
                          radius: 25,
                          spacing: 15,
                          strokeWidth: 2,
                          indexOfSeenStatus: 2,
                          numberOfStatus: snapshot.value.length,
                          padding: 4,
                          centerImageUrl: "https://picsum.photos/200/300",
                          seenColor: Colors.grey,
                          unSeenColor: Colors.red,
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.key.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(AppController.DateTimeStampBuilder(
                                DateTime.parse(data.values.elementAt(
                                    data.values.length - 1)["time"]))),
                          ],
                        ),
                        flex: 3,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(5),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                )
              ],
            )),
      );
  }

  MyStatusWidget() {
    //Improved widget for status view on 19Fab 2022 11:52AM
    return FutureBuilder(
        builder: (context, AsyncSnapshot? snapshot) {
          if (snapshot!.hasData) {
            if (snapshot.data.value != null) {
              return SizedBox(child: MyStatusRow(snapshot.data.value));
            } else {
              return SizedBox(child: MyStatusRow());
            }
          } else
            return Container(
              width: Get.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
        },
        future: StatusRef.child(userId.toString()).get());
  }
}

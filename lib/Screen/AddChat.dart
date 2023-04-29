import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/ContactModal.dart';
import 'package:firebase_chat_demo/Modal/MessageModal.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';

import '../Component/AppBarView.dart';
import '../Component/EditText.dart';
import '../Storage.dart';
import '../constant/ColorConstant.dart';
import '../constant/appConstant.dart';
import 'ChatDetails/ChatDetailScreen.dart';

class AddChat extends View<FirebaseDataModal> {
  AddChat() : super(FirebaseDataModal());
  Map data = {};
  List Arr = [];
  late DatabaseReference accountRef = $.model.getValue(#AccountDataRef);
  late DatabaseReference ChatListRef = $Model.getValue(#ChatListRef);

  int? userId;
  RxList? NumberArray = [].obs;

  @override
  void init(BuildContext context) {
    MyPrefs.getUserId().then((value) => userId = value);
    super.init(context);
    Syncing();
  }

  Syncing() async {
    Future(() {
      accountRef = $.model.getValue(#AccountDataRef);
    }).then((value) async {
      DataSnapshot? data = await accountRef.get();
      controller.Contactlist.value.forEach((e) {
        if (data.value[e.number] != null) {
          e.isRegistered = true;
        }
        print(e);
      });
    });
  }

  Future<void> _increment(userId) async {
    dynamic ChatRoomData = await ChatListRef.get();

    if (ChatRoomData.value == null) {
      ChatListRef.push().set({
        "user": data["number"].toString(),
        "title": "new chat initiated ",
        "users": [int.parse(data["number"].toString()), userId],
        "messages": [
          {
            "receiverId": int.parse(data["number"]),
            "user": data["name"],
            "title": data["number"].toString(),
            "senderId": userId,
            "users": [int.parse(data["number"].toString()), userId],
            "message": "new chat initiated ",
            "time": DateTime.now().toString()
          }
        ]
      });
      controller.Loader(false);
    } else {
      try {
        dynamic data2res = ChatRoomData.value.values.firstWhere((value) {
          return compareArray(
              value["users"], [userId, int.parse(data["number"])]);
        });
        // print(data2res);
        controller.Loader(false);
        Get.to(() =>
            ChatDetailScreen(
              ReceiverId: int.parse(data["number"]),
            ));
      } catch (er) {
        controller.Loader(false);
        ChatListRef.push().set({
          "user": data["number"].toString(),
          "title": "new chat initiated ",
          "users": [int.parse(data["number"].toString()), userId],
          "message": "new chat initiated ",
          "receiverId": int.parse(data["number"]),
          "senderId": userId,
          "time": DateTime.now().toString()
        }).whenComplete(() =>
            Get.to(() =>
                ChatDetailScreen(
                  ReceiverId: int.parse(data["number"]),
                )));
      }
    }
  }

  Future<void> _incrementGroup(object, userId) async {
    FirebaseDatabase(app: $Model.getValue(#firebaseapp))
        .reference()
        .child("ChatList")
        .update({"GroupId$userId": object}).whenComplete(
            () =>
            Get.to(() =>
                ChatDetailScreen(
                  GroupChat: object["users"],
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(title: "Available Users"),
      floatingActionButton: Arr.length > 1
          ? FloatingButtonView(
          icon: Icons.group_rounded, onPress: FloatingButtonClick)
          : SizedBox(),
      body: SafeArea(
          child: Stack(alignment: Alignment.center, children: [
            CustomScrollView(
              controller: ScrollController(initialScrollOffset: 0),
                slivers: [ SliverList(delegate: SliverChildListDelegate(<Widget>[
                  FirebaseAnimatedList(
                    shrinkWrap: true,
                    query: FirebaseDatabase(
                        app: $Model.getValue(#firebaseapp))
                        .reference()
                        .child("UserAccount"),
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      if (snapshot.value == null) {
                        NumberArray!([]);
                        return Container();
                      } else {
                        NumberArray!.value.add(snapshot.value["number"]);
                        return SizeTransition(
                          sizeFactor: animation,
                          child: userId.toString() == snapshot.value["number"]
                              ? Container()
                              : ContactRow(snapshot),
                        );
                      }
                    },
                  ),
                  Obx(() =>
                      Column(
                        children: controller.Contactlist.value
                            .map<Widget>(
                                (ContactModal e) => LocalUserContactRow(e))
                            .toList(),
                      )),
                ]),

                )]),
            Obx(() =>
            controller.Loader.value
                ? Positioned(
                child: CircularProgressIndicator(color: Colors.red))
                : Container())
          ])),
    );
  }

  LocalUserContactRow(ContactModal e) {
    if (e.isRegistered!) {
      return SizedBox();
    } else
      return GestureDetector(
        onTap: () {
          controller.Loader(true);
          data["number"] = e.number!;
          data["name"] = e.name;
          _increment($.model.getValue<int>(#userID));
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: new NetworkImage(
                            "https://picsum.photos/500",
                            scale: 10),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              e.number!,
                            )
                          ],
                        ),
                        flex: 2),
                    if (NumberArray!.value.contains(e.number!))
                      Expanded(
                        child: SizedBox(),
                        flex: 1,
                      ),
                    if (!NumberArray!.value.contains(e.number!))
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                              onTap: () {
                                String url =
                                    "sms:${e
                                    .number}?body=Let's chat on ${AppConst
                                    .AppName}! It's simple, fast and secure app. we can use to message each and call(coming soon).";
                                UrlLauncher(url);
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                padding: EdgeInsets.all(7),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: TextViewNew(
                                  "Invite".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: BoxDecoration(
                                    color: CustomColor.themeColor,
                                    borderRadius: BorderRadius.circular(5)),
                              ))),
                    // Expanded(
                    //     flex: 1,
                    //     child: Padding(
                    //       padding: EdgeInsets.only(right: 10),
                    //       child: ElevatedButton(
                    //           onPressed: () {
                    //             String url =
                    //                 "sms:${e.note}?body=Let's chat on ${AppConst.AppName}! It's simple, fast and secure app. we can use to message each and call(coming soon).";
                    //             UrlLauncher(url);
                    //           },
                    //           child: TextViewNew("Invite".toUpperCase())),
                    //     ))
                  ],
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                )
              ],
            )),
      );
  }

  ContactRow(snapshot, {userId}) {
    try {
      dynamic isInvite = controller.Contactlist.value
          .firstWhere((element) => element.number! == snapshot.value["number"]);
      print(isInvite);
    } catch (e) {}
    return GestureDetector(
      onLongPress: () => onLongPressClick(snapshot),
      onTap: () =>
      Arr.length > 0
          ? setState(() {
        Arr.contains(snapshot.key)
            ? Arr.remove(snapshot.key)
            : Arr.add(snapshot.key);
      })
          : {
        data["number"] = snapshot.value["number"],
        data["name"] = snapshot.value["user"],
        _increment(userId),
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: new NetworkImage(
                          "https://picsum.photos/500",
                          scale: 10),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${snapshot.value["user"].toString()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${snapshot.value["number"].toString()}',
                          )
                        ],
                      ),
                      flex: 2),
                  Arr.contains(snapshot.key)
                      ? Expanded(
                    child: Icon(
                      Icons.task_alt_sharp,
                      color: CustomColor.themeColor,
                    ),
                    flex: 1,
                  )
                      : Expanded(flex: 1, child: SizedBox())
                ],
              ),
              Divider(
                height: 1,
                thickness: 1,
              )
            ],
          )),
    );
  }

  onLongPressClick(snapshot) {
    setState(() {
      Arr.contains(snapshot.key)
          ? Arr.remove(snapshot.key)
          : Arr.add(snapshot.key);
    });
  }

  FloatingButtonClick() {
    int userId = $Model.getValue(#userID);
    List a = [];

    // a.addAll(Arr);
    Arr.forEach((element) {
      a.add(int.parse(element.toString()));
    });
    a.add(userId);
    // DatabaseReference ChatListRef = $Model.getValue(#ChatListRef);

    showDialog(
      context: Get.context!,
      builder: (context) =>
          CreateGroup(
            Callback: (name) {
              Get.back();
              Map<String, dynamic> data = new MessageModal(
                senderId: userId,
                time: DateTime.now().toString(),
                message: "new Group chat initiated",
                user: name,
                users: a,
              ).toJson();
              data.removeWhere((key, value) => key == null || value == null);
              _incrementGroup(data, userId);
            },
          ),
    );
  }
}

class CreateGroup extends StatelessWidget {
  Function? Callback;

  CreateGroup({this.Callback});

  String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create Group"),
        leading: IconButton(
            onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_sharp)),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(children: [
          SizedBox(height: 25),
          CircleAvatar(
            radius: 50,
            backgroundImage:
            NetworkImage("https://picsum.photos/500", scale: 10),
          ),
          SizedBox(height: 25),
          InputTextView(
            labelText: "Name",
            onChange: (value) => name = value.trim(),
          ),
          OutlinedButton(
            onPressed: () {
              name!.isEmpty
                  ? Get.snackbar("Invalid Name", "Please Enter a Valid Name")
                  : Callback!(name!.trim());
            },
            child: TextViewNew(
              "Create",
              color: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(CustomColor.themeColor)),
          )
        ]),
      ),
    );
  }
}

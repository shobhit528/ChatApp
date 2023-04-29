import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../Modal/firebaseDataModal.dart';
import '../Storage.dart';
import '../Utils/utils.dart';
import '../bloc/dummy.dart';
import '../constant/ColorConstant.dart';
import '../constant/appConstant.dart';
import 'AddChat.dart';
import 'ChatDetails/ChatDetailScreen.dart';

class ChatScreen extends View<FirebaseDataModal> {
  ChatScreen() : super(FirebaseDataModal());
  int userId=controller.stateVariable.userId;


  @override
  void init(BuildContext context) {
    super.init(context);

    controller.LiveLocationShared.listen((value) {
      Utils.GetCurrentLocation().listen((event) {
        controller.UserLatLong(new LatLng(event.latitude!, event.longitude!));
        if (controller.LiveLocationShared.value)
          controller.databaseRef.UserAccountReference.child("$userId").update(
              {"latitude": event.latitude, "longitude": event.longitude});
      });
    });
    print("==============>${stateVariable.userId}<====================");
    // Provider.of<DBRef>(context,listen: false).reference!.get().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: $.watchFor<DatabaseReference>(#ChatListRef,
            builder: $.builder1((ChatListing) => Column(
              children: <Widget>[
                if (ChatListing != null)
                  Flexible(
                    child: FirebaseAnimatedList(
                      query: ChatListing,
                      sort: (a, b) {
                        try {
                          return DateTime.parse(b.value!['time'])
                              .compareTo(DateTime.parse(a.value!['time']));
                        } catch (er) {
                          return 0;
                        }
                      },
                      itemBuilder: (BuildContext context,
                          DataSnapshot snapshot,
                          Animation<double> animation,
                          int index) {
                        if (controller.databaseRef.UserAccountReference != null)
                          controller.databaseRef.UserAccountReference.child("$userId").get().then((value) {
                            var data =
                            new Map<String, dynamic>.from(value.value);
                            controller.UserProfile(data);
                          });

                        return SizeTransition(
                          sizeFactor: animation,
                          child: ChatRow(snapshot),
                        );
                      },
                    ),
                  ),
              ],
            ))),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CustomColor.themeColor,
          onPressed: () {
            Get.to(() => AddChat());
          },
          tooltip: 'Increment',
          child: new Icon(Icons.message, color: CustomColor.white, size: 30),
        ));
  }

  ChatRow(snapshot) {
    if (snapshot.value["users"] != null &&
        !snapshot.value["users"].contains(userId)) {
      return Container();
    } else {
      return GestureDetector(
        onLongPress: () => showDialog(
            context: Get.context!,
            builder: (BuildContext context) => new AlertDialog(
                  title: TextViewNew(Provider.of<AppConst>(context).deleteMsg),
                  content:
                      TextViewNew(Provider.of<AppConst>(context).sureDeleteMsg),
                  actions: [
                    TextView(
                        label: Provider.of<AppConst>(context).no,
                        color: Colors.red,
                        onPress: () => Get.back()),
                    TextView(
                        label: Provider.of<AppConst>(context).yes,
                        color: CustomColor.themeColor,
                        onPress: () => DeleteRow(snapshot)),
                  ],
                )),
        onTap: () {
          if (snapshot.value["users"] != null &&
              snapshot.value["users"].contains(userId) &&
              snapshot.value["users"].length > 2) {
            Get.to(() => ChatDetailScreen(
                  GroupChat: snapshot.value["users"],
                  ChatListKey: snapshot.key,
                ));
          } else if (snapshot.value["users"] != null &&
              snapshot.value["users"].contains(userId))
            Get.to(() => ChatDetailScreen(
                  ReceiverId: int.parse(
                      snapshot.value["users"][1].toString() == userId.toString()
                          ? snapshot.value["users"][0].toString()
                          : snapshot.value["users"][1].toString()),
                  ChatListKey: snapshot.key,
                ));
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Container(
                    child: Row(
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
                        SizedBox(width: 10),
                        Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${snapshot.value["users"].toString().replaceAll("[", "").replaceAll("]", "").replaceAll("$userId", "")}'
                                      .replaceFirst(",", "")
                                      .trim(),
                                  maxLines: 1,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${snapshot.value["message"].toString()}',
                                )
                              ],
                            ),
                            flex: 3),
                        Expanded(
                            child: TextViewNew(controller.DateTimeStampBuilder(
                                DateTime.parse(snapshot.value["time"]))),
                            flex: 2)
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5)),
                Divider(
                  height: 1,
                  thickness: 1,
                )
              ],
            )),
      );
    }
  }

  DeleteRow(snapshot) {
    controller.databaseRef.MessageListReference.get().then((DataSnapshot value) {
      if (value.value != null) {
        value.value.forEach((e, j) {
          if (j["receiverId"].toString() ==
                  snapshot.value["receiverId"].toString() &&
              j["senderId"].toString() ==
                  snapshot.value["senderId"].toString()) {
            // print("delete msg too");
            controller.databaseRef.MessageListReference.remove();
          }
        });
      }
      // print("delete conversion too");
      controller.databaseRef.ChatListReference.child(snapshot.key!).remove();
    });
  }
}

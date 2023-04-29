import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_demo/Component/AnimatedFiller.dart';
import 'package:firebase_chat_demo/Modal/FilePickerModal.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contact.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvvm/mvvm.dart';

import '../../Component/AppBarView.dart';
import '../../Component/RecorderAndPlayer.dart';
import 'ChatDetailsFunction.dart';
import 'VideoCallingScreen.dart';

class ChatDetailScreen extends View<FirebaseDataModal> {
  ChatDetailScreen({this.ReceiverId, this.GroupChat, this.ChatListKey})
      : super(FirebaseDataModal());
  String? ChatListKey;
  var Userid = 0.obs, ImageFile = "".obs, firstKey = "".obs;
  TextEditingController inputController = new TextEditingController();

  int lengthcounter = 0;
  int? ReceiverId;
  List? GroupChat;
  final Recorder recorder = Recorder();
  final Player player = Player();
  AnimationController? animationController;
  late DatabaseReference messageRef = $.model.getValue(#MessageViewRef);
  late DatabaseReference accountRef = $.model.getValue(#AccountDataRef);
  late DatabaseReference chatListRef = $.model.getValue(#ChatListRef);
  late FS.FirebaseStorage fireStoreRef = $.model.getValue(#FireStore);

  @override
  void init(BuildContext context) {
    MyPrefs.getUserId().then((value) => Userid(value));
    super.init(context);
    recorder.init();
    player.init();
    print(ChatListKey!);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    recorder.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.themeColor,
        appBar: AppBarView(
            title: "${GroupChat ?? ReceiverId}"
                .toString()
                .replaceAll("[", "")
                .replaceAll("]", "")
                .replaceAll("$Userid", "")
                .replaceFirst(",", ""),
            CustomWidget: GestureDetector(
              onTap: () => PopupMenuButton<String>(
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'Logout', 'Settings', 'Profile'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  InitDisposeCalling(type: value).then((int? uid) {
                    showDialog(
                        context: context,
                        builder: (builder) => VideoCallingApp(
                              isCallAudio: value == "Audio Call",
                              uid: uid,
                              CallerId: GroupChat ?? ReceiverId,
                            ));
                  });
                },
                child: Icon(Icons.add_ic_call_rounded),
                itemBuilder: (BuildContext context) {
                  return {'Audio Call', 'Video Call'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            )),
        body: SafeArea(
          child: Container(
            decoration: AppWidget().chatImageDecoration,
            child: $.watchFor<DatabaseReference>(#MessageViewRef,
                builder: $.builder1((MessageListing) => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (MessageListing != null)
                          Flexible(
                            child: FirebaseAnimatedList(
                              reverse: true,
                              query: MessageListing,
                              sort: (a, b) {
                                return DateTime.parse(b.value!['time'])
                                    .compareTo(
                                        DateTime.parse(a.value!['time']));
                              },
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                if (snapshot.value != null) {
                                  lengthcounter = index + 1;
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    child: ChatRow(snapshot.value,
                                        key: snapshot.key),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: BottomBar(),
                        )
                      ],
                    ))),
          ),
        ));
  }

  ChatRow(data, {key}) {
    if (firstKey.value.isEmpty && data["mediaType"] == "liveLocation") {
      firstKey(key);
    }
    if (data["users"] != null &&
        data["users"].contains(Userid.value) &&
        (data["users"].contains(ReceiverId) ||
            compareArray(data["users"], GroupChat ?? []))) {
      bool isSendingUser = data["senderId"] == Userid.value;
      return Container(
          margin: EdgeInsets.only(
              left: isSendingUser ? 100 : 10,
              right: isSendingUser ? 10 : 100,
              top: 5,
              bottom: 5),
          alignment:
              isSendingUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
              crossAxisAlignment: isSendingUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  isSendingUser ? Container() : UserProfileImage,
                  Wrap(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5.0,
                            sigmaY: 5.0,
                          ),
                          child: Container(
                              constraints:
                                  BoxConstraints(maxWidth: Get.width / 1.65),
                              decoration:
                                  chatDecoration(isSender: isSendingUser),
                              padding: data["mediaType"] == "text"
                                  ? EdgeInsets.all(10)
                                  : EdgeInsets.only(
                                      bottom: data["message"].isEmpty ? 0 : 5,
                                      top: 5,
                                      left: 5,
                                      right: 5),
                              child: Column(
                                children: [
                                  RenderChatView(data["mediaType"], data, key,
                                      isSendingUser)
                                ],
                              )),
                        ),
                      ),
                      // Container(
                      //     constraints:
                      //     BoxConstraints(maxWidth: Get.width / 1.65),
                      //     decoration: chatDecoration(isSender: isSendingUser),
                      //     padding: data["mediaType"] == "text"
                      //         ? EdgeInsets.all(10)
                      //         : EdgeInsets.only(
                      //         bottom: data["message"].isEmpty ? 0 : 5,
                      //         top: 5,
                      //         left: 5,
                      //         right: 5),
                      //     child: Column(
                      //       children: [
                      //         RenderChatView(
                      //             data["mediaType"], data, key, isSendingUser)
                      //       ],
                      //     ))
                    ],
                  ),
                  isSendingUser ? UserProfileImage : Container()
                ]),
                ChatTimeWidget(
                    condition: isSendingUser,
                    time: data["time"],
                    color: CustomColor().textColor),
              ]));
    } else {
      return Container();
    }
  }

  BottomBar() {
    RxBool isShow = false.obs,
        isAudioMessage =
            (ImageFile.value.isEmpty && inputController.value.text.isEmpty).obs;
    final AddButton = IconButton(
      icon: Icon(Icons.add),
      onPressed: () => BottomAttachmentPicker(
          Get.context, (response) => ResponseHandling(response)),
    );
    final SendButton = GestureDetector(
      child: SizedBox(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: CustomColor.themeColor, shape: BoxShape.circle),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Obx(
              () => isAudioMessage.isTrue ? Icon(Icons.mic) : Icon(Icons.send)),
        ),
      ),
      onTap: () => isAudioMessage.isTrue ? {} : SendMessage(),
      onTapDown: isAudioMessage.isFalse
          ? (_) {}
          : (_) async {
              isShow(true);
              try {
                await recorder.startRecord();
              } catch (e) {}
            },
      onTapUp: isAudioMessage.isFalse
          ? (_) {}
          : (_) async {
              isShow(false);
              try {
                await recorder.stopRecord();
                // player.startPlaying(url: recorder.tofile, callback: (bool i) {});
                SendVoiceMessage(path: recorder.tofile);
              } catch (e) {}
            },
    );

    return $.watchFor<DatabaseReference>(#MessageViewRef,
        builder: $.builder1((messages) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => ImageFile.value.isEmpty
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        margin:
                            EdgeInsets.symmetric(horizontal: 65, vertical: 5),
                        child: Stack(
                          children: [
                            Image.file(
                              File(ImageFile.value),
                              height: 60,
                              width: 60,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              child: GestureDetector(
                                  child: Icon(Icons.cancel),
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => ImageFile("")),
                              top: 0,
                              right: 0,
                            )
                          ],
                        ),
                      )),
                Obx(() => isShow.isTrue
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: new AnimatedFillerButton(
                            callback: (controller) {
                              animationController = controller;
                            },
                          ),
                        ))
                    : SizedBox()),
                SizedBox(
                  height: 50,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AddButton,
                        UserInputField(
                            inputController: inputController,
                            onChange: (value) {
                              setState(() {});
                            }),
                        SendButton
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  ResponseHandling(res) async {
    Map<String, dynamic> data = new Map<String, dynamic>.from(res);
    switch (data["type"]) {
      case "contact":
        Get.back();
        sendContact(data["data"]);
        break;
      case "document":
        sendDocument(data["data"]);
        break;
      case "music":
        SendVoiceMessage(selectedfile: data["data"]);
        break;
      case "image":
        ImageFile(data["data"].path ?? "");
        break;
      case "location":
        try {
          if (data["data"]["liveLocation"] != null) {
            Navigator.of(Get.context!).pop();
            SendLocation(timeCount: data["data"]["timeCount"]);
            StartLiveLocationSharing(callback: (seconds) {});
          }
        } catch (er) {
          controller.UserLatLong(
              new LatLng(data["data"].latitude, data["data"].longitude));
          SendLocation(latlng: data["data"]);
        }
        break;
    }
  }

  SendVoiceMessage({String? path, PickedFileModal? selectedfile}) async {
    controller.Loader(true);
    String soundUrl = path == null
        ? await controller.UploadAudioToServer(
            selectedfile!.path!, fireStoreRef,
            name: selectedfile.name!)
        : await controller.UploadAudioToServer(path, fireStoreRef);
    Map<String, dynamic> data = CreateObject();
    if (path == null) {
      double length = await lengthOfAudio(File(selectedfile!.path!));
      data["duration"] = length;
      data["mediaType"] = "music";
      data["audio"] = soundUrl;
      data["name"] = selectedfile.name;
      data["size"] =
          "${(double.parse(selectedfile.size!.toString())) / 1000}KB";
    } else {
      data["mediaType"] = "audio";
      data["audio"] = soundUrl;
      data["duration"] = animationController!.lastElapsedDuration!.inSeconds;
    }

    // data.removeWhere((key, value) => key == null || value == null);
    // messageRef.push().update(data);
    CommitChanges(data);
    controller.Loader(false);
  }

  SendMessage() async {
    if (!inputController.value.text.trim().isEmpty ||
        !ImageFile.value.isEmpty) {
      controller.Loader(true);
      Map<String, dynamic> data = CreateObject();

      if (!ImageFile.value.isEmpty) {
        String url =
            await controller.UploadImageToServer(ImageFile.value, fireStoreRef);
        data["image"] = url;
        data["mediaType"] = "image";
      } else {
        data["mediaType"] = "text";
      }

      // data.removeWhere((key, value) => key == null || value == null);
      // messageRef.push().update(data);
      CommitChanges(data);
      inputController.clear();
      ImageFile("");
      controller.Loader(false);
    } else {
      Get.snackbar("Enter Message", "Enter Valid/Non-Empty message to send",
          backgroundColor: controller.isDarkMode ? Colors.black : Colors.white);
    }
  }

  SendLocation({LocationData? latlng, int? timeCount}) async {
    controller.Loader(true);
    Map<String, dynamic> data = CreateObject();

    if (latlng != null) {
      data["mediaType"] = "location";
      data["latitude"] = latlng.latitude;
      data["longitude"] = latlng.longitude;
    } else {
      data["mediaType"] = "liveLocation";
      data["durationSec"] = timeCount;
      data["endTime"] =
          DateTime.now().add(Duration(seconds: timeCount!)).toString();
    }
    // data.removeWhere((key, value) => key == null || value == null);
    // messageRef.push().update(data);
    CommitChanges(data);
    controller.Loader(false);
    if (data["mediaType"] == "liveLocation") {
      data["users"].forEach((e) {
        if (e.toString() != data["senderId"].toString()) {
          accountRef
              .child(data["senderId"].toString())
              .child("liveSharing")
              .update({
            e.toString(): {"duration": data["durationSec"], "isSharing": true}
          });
        }
      });

      Timer.periodic(Duration(seconds: 1), (timer) {
        if (timer.tick >= timeCount!) {
          data["users"].forEach((e) {
            if (e.toString() != data["senderId"].toString()) {
              accountRef
                  .child(data["senderId"].toString())
                  .child("liveSharing")
                  .update({
                e.toString(): {"duration": 0, "isSharing": false}
              });
            }
          });

          timer.cancel();
          StopLiveLocationSharing();
          DatabaseFunction().StopLocationSharing(childName: firstKey.value);
        } else {
          data["users"].forEach((e) {
            if (e.toString() != data["senderId"].toString()) {
              accountRef
                  .child(data["senderId"].toString())
                  .child("liveSharing")
                  .update({
                e.toString(): {
                  "duration": data["durationSec"] - timer.tick,
                  "isSharing": true
                }
              });
            }
          });
        }
      });
    }
  }

  RenderChatView(type, data, [key, isSendingUser]) {
    switch (type) {
      case "contact":
        return FutureBuilder(
            future: accountRef.child(data["number"]).get(),
            builder: (context, AsyncSnapshot? snapshot) {
              if (snapshot!.data != null) {
                if (snapshot.data.value != null) {
                  return SizedBox(
                    child: ContactWidget(
                        name: data["name"],
                        number: data["number"],
                        isAvailable: true),
                  );
                } else {
                  return SizedBox(
                    child: ContactWidget(
                        name: data["name"],
                        number: data["number"],
                        isAvailable: false),
                  );
                }
              } else {
                return SizedBox();
              }
            });
      case "music":
        return SizedBox(
          width: 175,
          child: musicWidget(url: data["audio"], name: data["name"]),
        );
      case "document":
        return SizedBox(
          width: 175,
          child: documentWidget(url: data["url"], name: data["name"]),
        );
      case "audio":
        try {
          return player.buildWidget(data["audio"], data["duration"]);
        } catch (e) {
          return Icon(Icons.play_arrow);
        }

      case "text":
        try {
          return Column(children: [
            data["message"].isEmpty
                ? SizedBox()
                : Text(
                    data["message"] ?? "",
                    style: TextStyle(color: CustomColor.white
                        // !isSendingUser ? CustomColor.white : CustomColor().textColor
                        ),
                  )
          ]);
        } catch (er) {
          return SizedBox();
        }

      case "image":
        try {
          return Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(children: [
                GestureDetector(
                    onLongPress: !isSendingUser
                        ? () {}
                        : () {
                            $.model
                                .getValue<FS.FirebaseStorage>(#FireStore)
                                .refFromURL(data["image"])
                                .delete()
                                .then((value) {
                              $.model
                                  .getValue<DatabaseReference>(#MessageViewRef)
                                  .child(key)
                                  .remove();
                            });
                          },
                    onTap: () => ImageOpener(Image.network(
                          data["image"],
                          fit: BoxFit.cover,
                        )),
                    behavior: HitTestBehavior.translucent,
                    child: CachedNetworkImage(
                      imageUrl: data["image"].trim(),
                      // height: 200,width: 100,
                      fadeInCurve: Curves.easeIn,
                      fadeInDuration: Duration(milliseconds: 500),
                      fadeOutCurve: Curves.easeOut,
                      fadeOutDuration: Duration(milliseconds: 500),
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: CustomColor.white),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
                data["message"].isEmpty
                    ? SizedBox()
                    : Text(
                        data["message"] ?? "",
                        style: TextStyle(color: CustomColor().textColor),
                      )
              ]));
        } catch (er) {
          return SizedBox();
        }
      case "location":
        try {
          return Column(children: [
            Container(
              padding: EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 5),
              child: Stack(
                children: [
                  SizedBox(
                    child: Image.asset('assets/map.png'),
                    // child: new MapScreen(),
                    height: 200,
                    width: 200,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      $.model
                          .getValue<DatabaseReference>(#MessageViewRef)
                          .child(key)
                          .remove();
                    },
                    onTap: () => UrlLauncher(
                        "https://www.google.com/maps/search/?api=1&query=${data["latitude"]}%2C${data["longitude"]}"),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
            ),
            data["message"].isEmpty
                ? SizedBox()
                : Text(
                    data["message"] ?? "",
                    style: TextStyle(color: CustomColor().textColor),
                  )
          ]);
        } catch (er) {
          return SizedBox();
        }
      case "liveLocation":
        try {
          bool lapsedTime =
              DateTime.now().isAfter(DateTime.parse(data["endTime"]));
          return Column(children: [
            LiveLocationWidget(senderId: data["senderId"]),
            data["message"].isEmpty
                ? SizedBox()
                : Text(
                    data["message"] ?? "",
                    style: TextStyle(color: CustomColor().textColor),
                  ),
            if (isSendingUser)
              LiveLocationTextSenderWidget(
                  condition: lapsedTime,
                  onPress: () {
                    // getCurrentLocation((data) {
                    //   $.model
                    //       .getValue<DatabaseReference>(#MessageViewRef)
                    //       .child(key)
                    //       .update({
                    //     'endTime': DateTime.now().toString(),
                    //     "latitude": data.latitude,
                    //     "longitude": data.longitude,
                    //   });
                    // });
                    DatabaseFunction().StopLocationSharing(childName: key);
                    StopLiveLocationSharing();
                  }),
            if (!isSendingUser)
              LiveLocationTextReceiverWidget(
                  senderId: data["senderId"], condition: lapsedTime)
          ]);
        } catch (er) {
          return SizedBox();
        }

      case "call":
        return CallingWidget(
            data: data,
            isSender: isSendingUser,
            CallerId: GroupChat ?? ReceiverId,
            callback: (res) {
              Get.back();
              if (res != null) HangCall(key);
            });
      default:
        return SizedBox();
    }
  }

  HangCall(key) {
    messageRef.child(key).update({"action": "endCalling"});
  }

  sendDocument(PickedFileModal value) async {
    controller.Loader(true);
    Map<String, dynamic> object = CreateObject();
    object["mediaType"] = "document";
    object["name"] = value.name;
    object["size"] = "${value.size} bytes";

    String? docurl = await controller.UploadDocumentToServer(
        File(value.path!).readAsBytesSync(), fireStoreRef,
        name: value.name);
    object["url"] = docurl;
    // object.removeWhere((key, value) => key == null || value == null);
    // messageRef.push().update(object);
    CommitChanges(object);
    controller.Loader(false);
  }

  sendContact(Contact contact) {
    controller.Loader(true);
    Get.back();
    Map<String, dynamic> object = CreateObject();
    object["mediaType"] = "contact";
    object["number"] = contact.note!;
    object["name"] = contact.displayName;
    // object.removeWhere((key, value) => key == null || value == null);
    // messageRef.push().update(object);
    CommitChanges(object);
    controller.Loader(false);
  }

  Future<int?> InitDisposeCalling({
    String? type,
  }) async {
    Map<String, dynamic> object = CreateObject();
    object["mediaType"] = "call";
    object["type"] = type!;
    object["action"] = "startCalling";
    object["uid"] = Random().nextInt(100000000);
    CommitChanges(object);
    return object["uid"];
  }

  Map<String, dynamic> CreateObject() {
    dynamic data = {
      "id": "$lengthcounter",
      "senderId": Userid.value,
      "time": DateTime.now().toString(),
      "message": inputController.value.text.trim(),
    };

    if (ReceiverId != null) {
      data["receiverId"] = ReceiverId;
      data["users"] = [Userid.value, ReceiverId];
    } else {
      data["users"] = GroupChat;
    }

    return data;
  }

  CommitChanges(Map<String, dynamic> object) {
    object.removeWhere((key, value) => key == null || value == null);
    messageRef.push().set(object);
    chatListRef.child(ChatListKey!).update({"time": DateTime.now().toString()});
  }
}

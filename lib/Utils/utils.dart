import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_demo/Component/ContactList.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/ContactModal.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Screen/ShareLocation/ShareLocation.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart' as Loc;
import 'package:mvvm/mvvm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Component/AppBarView.dart';
import '../Modal/CountryCode.dart';
import '../Modal/FilePickerModal.dart';
import '../Screen/ChatDetails/ChatDetailScreen.dart';
import '../constant/appConstant.dart';

class Utils {
  // static Future<List<String>> getDeviceDetails() async {
  //   String deviceName;
  //   String deviceVersion;
  //   String identifier;
  //   final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  //   try {
  //     if (Platform.isAndroid) {
  //       var build = await deviceInfoPlugin.androidInfo;
  //       deviceName = build.model;
  //       deviceVersion = build.version.toString();
  //       identifier = build.androidId; //UUID for Android
  //     } else if (Platform.isIOS) {
  //       var data = await deviceInfoPlugin.iosInfo;
  //       deviceName = data.name;
  //       deviceVersion = data.systemVersion;
  //       identifier = data.identifierForVendor; //UUID for iOS
  //     }
  //   } on PlatformException {
  //     print('Failed to get platform version');
  //   }
  //   return [deviceName, deviceVersion, identifier];
  // }

  static showImagePicker(context, Function callback,
      {Function? onErrorCallback}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(Provider.of<AppConst>(context).photoLibrary),
                      onTap: () {
                        imgFromGallery((image) {
                          if (image == null || onErrorCallback != null)
                            onErrorCallback!("error");
                          else
                            fixExifRotation(image.path)
                                .then((value) => callback(value));
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(Provider.of<AppConst>(context).camera),
                    onTap: () {
                      _imgFromCamera((image) {
                        if (image == null || onErrorCallback != null)
                          onErrorCallback!("error");
                        else
                          fixExifRotation(image.path)
                              .then((value) => callback(value));
                      });
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  static Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    final height = originalImage!.height;
    final width = originalImage.width;

    // Let's check for the image size
    if (height >= width) {
      // I'm interested in portrait photos so
      // I'll just return here
      return originalFile;
    }

    // We'll use the exif package to read exif data
    // This is map of several exif properties
    // Let's check 'Image Orientation'
    final exifData = await readExifFromBytes(imageBytes);

    late img.Image fixedImage;

    if (height < width) {
      try {
        // rotate
        if (exifData['Image Orientation']!.printable.contains('Horizontal')) {
          fixedImage = img.copyRotate(originalImage, 90);
        } else if (exifData['Image Orientation']!.printable.contains('180')) {
          fixedImage = img.copyRotate(originalImage, -90);
        } else {
          fixedImage = img.copyRotate(originalImage, 0);
        }
      } catch (e) {
        fixedImage = img.copyRotate(originalImage, 90);
      }
    }

    // Here you can select whether you'd like to save it as png
    // or jpg with some compression
    // I choose jpg with 100% quality
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }

  static MediaPicker(Function(PickedFileModal) Callback,
      {String type = "document"}) async {
    try {
      FilePickerResult? result = type == "document"
          ? await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', '.xml', '.txt'])
          : await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null) {
        // List<File> files = result.paths.map((path) => File(path!)).toList();
        // File files = File(!);
        Callback(new PickedFileModal(
            result.paths[0], result.names[0], result.sizes[0]));
      } else {
        // User canceled the picker
      }
    } catch (err) {}
  }

  static _imgFromCamera(Function Callback) async {
    dynamic image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image != null) Callback(image);
  }

  static imgFromGallery(Function Callback) async {
    dynamic image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (image != null) Callback(image);
  }

  static Stream<Loc.LocationData> GetCurrentLocation() async* {
    Loc.Location location = new Loc.Location();
    bool _serviceEnabled;
    Loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    yield* location.onLocationChanged;
  }
}

ImageOpener(Widget image) {
  Navigator.of(Get.context!).push(new MaterialPageRoute(
    builder: (context) => Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Center(
          child: Hero(
            tag: "hero-tag",
            child: image,
          ),
        ),
        Positioned(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              height: 50,
              width: 50,
              child: TextView(
                label: "X",
                type: 1,
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          top: 25,
          right: 10,
        )
      ]),
    ),
  ));
}

Future<PermissionStatus> getContactPermission() async {
  final PermissionStatus permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.denied) {
    final Map<Permission, PermissionStatus> permissionStatus =
        await [Permission.contacts].request();
    return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
  } else if (permission == PermissionStatus.denied) {
    PermissionStatus status = await Permission.contacts.request();
    return status;
  } else {
    return permission;
  }
}

FetchContactList() async {
  controller.Contactlist([]);
  await Contacts.streamContacts().forEach((contact) {
    contact.phones.forEach((e) {
      controller.Contactlist.add(new ContactModal(
          name: contact.displayName ?? e.value,
          isRegistered: false,
          number: e.value!
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("(", "")
              .replaceAll(")", "")));
      // listContacts.add(new Contact(displayName: contact.displayName, note: e.value));
    });
  });
}

BottomAttachmentPicker(context, Function callback) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SafeArea(
            child: ClipRect(
                child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            color: Colors.white54,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: new GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: <Widget>[
                TileSelector(
                    Name: Provider.of<AppConst>(context).camera,
                    iconData: Icons.camera_alt,
                    onPress: () {
                      Utils._imgFromCamera((image) =>
                          callback({"type": "image", "data": image}));
                      Navigator.of(context).pop();
                    }),
                TileSelector(
                    Name: Provider.of<AppConst>(context).gallery,
                    iconData: Icons.photo_library,
                    onPress: () {
                      Utils.imgFromGallery((image) =>
                          callback({"type": "image", "data": image}));
                      Navigator.of(context).pop();
                    }),
                TileSelector(
                    Name: Provider.of<AppConst>(context).location,
                    iconData: Icons.location_on_rounded,
                    onPress: () {
                      showDialog(
                          context: context,
                          builder: (context) => ShareLocation(onResult: (res) {
                                Navigator.of(context).pop();
                                callback({"type": "location", "data": res});
                                Navigator.of(context).pop();
                              }));
                    }),
                TileSelector(
                    Name: Provider.of<AppConst>(context).document,
                    iconData: Icons.document_scanner_rounded,
                    onPress: () {
                      Utils.MediaPicker((document) {
                        callback({"type": "document", "data": document});
                        Navigator.of(context).pop();
                      });
                    }),
                TileSelector(
                    Name: Provider.of<AppConst>(context).audio,
                    iconData: Icons.music_note_outlined,
                    onPress: () {
                      Utils.MediaPicker((music) {
                        if (music != null)
                          callback({"type": "music", "data": music});
                        Navigator.of(context).pop();
                      }, type: "audio");
                    }),
                TileSelector(
                    Name: Provider.of<AppConst>(context).contact,
                    iconData: Icons.perm_contact_cal_outlined,
                    onPress: () {
                      Navigator.of(Get.context!).push(new MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBarView(
                              title:
                                  Provider.of<AppConst>(context).selectContact),
                          backgroundColor: Colors.black,
                          body: ContactList(callback: (ContactModal contact) {
                            Navigator.of(context).pop();
                            callback({"type": "contact", "data": contact});
                          }),
                        ),
                      ));
                    })
              ],
            ),
          ),
        )));
      });
}

class GridDataClass {
  String? name;
  IconData? icon;
  Function? onPress;

  GridDataClass({this.name, this.icon, this.onPress});
}

Widget TileSelector({Name, iconData, onPress}) {
  return new GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPress,
      child: Column(children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: CustomColor.pinkLight,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            iconData,
            size: 30,
          ),
        ),
        TextViewNew(
          Name,
          color: CustomColor().textColor,
        ),
      ]));
}

getCurrentLocation(Function(Loc.LocationData) callback) {
  Loc.Location location = new Loc.Location();
  location.getLocation().then((value) => callback(value));
}

Future<double> lengthOfAudio(File audio) async {
  final player = AudioPlayer();
  var duration = await player.setUrl(audio.path);
  return double.parse(duration!.inSeconds.toString());
}

UrlLauncher(url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}

bool compareArray(arr1, arr2) {
  var a = arr1;
  var b = arr2;

  var condition1 = a.toSet().difference(b.toSet()).isEmpty;
  var condition2 = a.length == b.length;
  var isEqual = condition1 && condition2;
  return isEqual;
}

StartLiveLocationSharing({Function? callback}) async {
  if (Platform.isAndroid) {
    var hasPermissions = await FlutterBackground.hasPermissions;
    bool isEnabled = FlutterBackground.isBackgroundExecutionEnabled;
    if (hasPermissions && !isEnabled) {
      var a = await FlutterBackground.enableBackgroundExecution();
      controller.LiveLocationShared(true);
    }
  } else {
    controller.LiveLocationShared(true);
  }
}

StopLiveLocationSharing() async {
  if (Platform.isAndroid) {
    bool isEnabled = FlutterBackground.isBackgroundExecutionEnabled;
    if (isEnabled) {
      await FlutterBackground.disableBackgroundExecution();
      controller.LiveLocationShared(false);
    }
  } else {
    controller.LiveLocationShared(false);
  }
}

CountryListApi() async {
  final String response = await rootBundle.loadString("lib/Utils/country.json");
  CountryCode code = countryCodeFromMap(response);
  controller.countryList(code.countries);
}

// FileDownloader(String url) async {
// try {
// #  image_downloader: ^0.31.0
// var imageId = await ImageDownloader.downloadImage(url);
// if (imageId == null) {
//   return;
// }
//
// Below is a method of obtaining saved image information.
// var fileName = await ImageDownloader.findName(imageId);
// var path = await ImageDownloader.findPath(imageId);
// var size = await ImageDownloader.findByteSize(imageId);
// var mimeType = await ImageDownloader.findMimeType(imageId);
// } on PlatformException catch (error) {
//   print(error);
// }
// }

InitChatMessage(
    {DatabaseReference? chatListRef,
    int? userId,
    int? receiverId,
    String? name}) async {
  chatListRef!.push().set({
    "user": name,
    "title": "new chat initiated ",
    "users": [receiverId, userId],
    "message": "new chat initiated ",
    "receiverId": receiverId,
    "senderId": userId,
    "time": DateTime.now().toString()
  }).whenComplete(() => Get.to(() => ChatDetailScreen(
        ReceiverId: receiverId,
      )));
}

class DatabaseFunction extends View<FirebaseDataModal> {
  DatabaseFunction() : super(FirebaseDataModal());
  late DatabaseReference messageRef = $.model.getValue(#MessageViewRef);
  late DatabaseReference accountRef = $.model.getValue(#AccountDataRef);
  late DatabaseReference chatListRef = $.model.getValue(#ChatListRef);
  late int Userid = $.model.getValue(#userID);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

  StartLocationSharing() {}

  StopLocationSharing({String? childName}) {
    getCurrentLocation((data) {
      messageRef.child(childName!).update({
        'endTime': DateTime.now().toString(),
        "latitude": data.latitude,
        "longitude": data.longitude,
      });
    });
  }

  Future<DatabaseReference>? AccountRefFunction() {
    Future(() {
      DatabaseReference accountRef = $.model.getValue(#AccountDataRef);
    }).then((value) {
      return accountRef;
    });
  }

  InitChatListMessage({String? name, int? receiverNumber}) async {
    Future(() {
      DatabaseReference chatListRef = $.model.getValue(#ChatListRef);
    }).then((value) {
      chatListRef.get().then((value) {
        Map<String, dynamic> respo = new Map<String, dynamic>.from(value.value);
        Iterable chatlisting = respo.values;
        try {
          dynamic isExist = chatlisting.firstWhere((element) {
            return (receiverNumber == element["receiverId"] &&
                Userid == element["senderId"]);
          });
          Get.to(() => ChatDetailScreen(
                ReceiverId: isExist["receiverId"],
              ));
        } catch (e) {
          InitChatMessage(
              chatListRef: chatListRef,
              userId: Userid,
              name: name,
              receiverId: receiverNumber);
        }
      });
    });
  }
}

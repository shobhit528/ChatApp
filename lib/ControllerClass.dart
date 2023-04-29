import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat_demo/Modal/ContactModal.dart';
import 'package:firebase_chat_demo/bloc/dummy.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'Modal/CountryCode.dart';

class Controller extends GetxController {
  RxBool DarkMode = false.obs;

  bool get isDarkMode => DarkMode.value;
  Map<String, dynamic> AppInfo = Map<String, dynamic>().obs;
  dynamic firebasedata = {}.obs;
  RxList datalist = [].obs;
  RxList<ContactModal> Contactlist = <ContactModal>[].obs;
  RxList<Country> countryList = <Country>[].obs;
  Rx<LatLng> UserLatLong = new LatLng(0.0, 0.0).obs;
  late var firstCamera;
  var UserId = 0.obs,
      UserProfile = {}.obs,
      selectedCountry =
          new Country(code: "", dialCode: "", name: "Invalid Country").obs;
  RxBool loggedin = false.obs,
      Loader = false.obs,
      LiveLocationShared = false.obs;

  StateVariable get stateVariable => GetIt.instance.get<StateVariable>();

  DBRef get databaseRef => GetIt.instance.get<DBRef>();

  SyncContact(DataSnapshot? accountRef) {
    // try {
    //   if (Contactlist.length > 0)
    //     Contactlist.value.map((e) {
    //       print(accountRef!.value[e.number]);
    //     });
    // } catch (e) {
    //   print(e);
    // }
  }

  Appinformation() async {
    // if (Platform.isAndroid) {
    //   var methodchannel = MethodChannel("enableWakeLock");
    //   dynamic data = await methodchannel.invokeMethod("getAppInfo");
    //   AppInfo["buildNumber"] = data["versionName"];
    //   AppInfo["version"] = data["versionCode"];
    // }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppInfo["appName"] = packageInfo.appName;
    AppInfo["buildNumber"] = packageInfo.buildNumber;
    AppInfo["version"] = packageInfo.version;
    AppInfo["buildSignature"] = packageInfo.buildSignature;
    AppInfo["packageName"] = packageInfo.packageName;
  }

  FormateTime(DateTime dt) => DateFormat('hh:mm aa').format(dt);

  FormateDate(DateTime dt) => DateFormat('ddMMyyyyhhmms').format(dt);

  String DateTimeStampBuilder(DateTime date) {
    DateTime now = DateTime.now();
    int num = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (num == -1) {
      return "Yesterday ${FormateTime(date)}";
    } else if (num == 0) {
      return "Today ${FormateTime(date)}";
    }
    return "${num} days ago".replaceFirst("-", "");
  }

  Future UploadImageToServer(String path, FS.FirebaseStorage ref) async {
    File imagefile = File(path); //convert Path to File
    Uint8List imagebytes = await imagefile.readAsBytes();
    await imagefile.writeAsBytes(imagebytes.buffer
        .asUint8List(imagebytes.offsetInBytes, imagebytes.lengthInBytes));
    FS.TaskSnapshot snapshot =
        await ref.ref().child("images/${DateTime.now()}").putFile(imagefile);
    if (snapshot.state == FS.TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
  }

  Future UploadAudioToServer(String path, FS.FirebaseStorage ref,
      {String? name}) async {
    FS.TaskSnapshot snapshot = await ref
        .ref()
        .child(
            "audios/${name ?? controller.FormateDate(DateTime.now()) + ".wav"}")
        .putFile(
            File(path),
            FS.SettableMetadata(
                contentType: name != null
                    ? 'audio/' + name.split(".")[1]
                    : 'audio/wav'));
    if (snapshot.state == FS.TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
  }

  Future UploadDocumentToServer(datafile, FS.FirebaseStorage ref,
      {String? name}) async {
    FS.TaskSnapshot snapshot =
        await ref.ref().child("documents/${name}").putData(datafile);
    if (snapshot.state == FS.TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
  }
}

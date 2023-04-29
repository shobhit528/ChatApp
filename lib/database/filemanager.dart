import 'dart:convert';
import 'dart:io';

import 'package:firebase_chat_demo/Modal/backupModal.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static FileManager? instance;

  FileManager.internal() {
    instance = this;
  }

  factory FileManager() => instance ?? FileManager.internal();

  Future<String> get directoryPath async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<File> get textFile async {
    final path = await directoryPath;
    return File("$path/userinformation.txt");
  }

  Future<File> get jsonFile async {
    final path = await directoryPath;
    return File("$path/ChatApp-backup.json");
  }

  Future<Map<String, dynamic>> readJsonFile() async {
    String filecontent = "";
    File file = await jsonFile;

    if (await file.existsSync()) {
      try {
        dynamic res = await file.readAsString();
        filecontent = res;
      } catch (e) {
      }
    } else {
    }

    return json.decode(filecontent);
  }

  Future<BackupModal> writeJsontoFile(
      {DatabaseReference? messageRef, DatabaseReference? chatRef}) async {
    int? userId = await MyPrefs.getUserId();
    List<dynamic> messagesList = [], chatList = [];
    await chatRef!.get().then((value) {
      Map<String, dynamic> Chatdata =
          new Map<String, dynamic>.from(value.value);
      Chatdata.forEach((key, value) {
        if (value["users"].contains(userId)) chatList.add(value);
      });
    });
    await messageRef!.get().then((value) {
      Map<String, dynamic> Messagedata =
          new Map<String, dynamic>.from(value.value);
      Messagedata.forEach((key, value) {
        if (value["users"].contains(userId)) messagesList.add(value);
      });
    });

    final BackupModal backupModal =
        new BackupModal(chatList: chatList, messagesList: messagesList);
    File file = await jsonFile;

    await file.writeAsString(json.encode(backupModal));
    return backupModal;
  }

  Future<String> readtextFile() async {
    String filecontent = "";
    File file = await textFile;

    if (await file.existsSync()) {
      try {
        dynamic res = await file.readAsString();
        filecontent = res;
      } catch (e) {
      }
    } else {
    }

    return filecontent;
  }

  Future<BackupModal> writeTextFile(
      {DatabaseReference? messageRef, DatabaseReference? chatRef}) async {
    int? userId = await MyPrefs.getUserId();
    List<dynamic> messagesList = [], chatList = [];
    await chatRef!.get().then((value) {
      Map<String, dynamic> Chatdata =
          new Map<String, dynamic>.from(value.value);
      Chatdata.forEach((key, value) {
        if (value["users"].contains(userId)) chatList.add(value);
      });
    });
    await messageRef!.get().then((value) {
      Map<String, dynamic> Messagedata =
          new Map<String, dynamic>.from(value.value);
      Messagedata.forEach((key, value) {
        if (value["users"].contains(userId)) messagesList.add(value);
      });
    });

    final BackupModal backupModal =
        new BackupModal(chatList: chatList, messagesList: messagesList);
    File file = await textFile;

    await file.writeAsString(json.encode(backupModal));
    return backupModal;
  }
}

import 'package:firebase_chat_demo/ControllerClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class MyPrefs {
  static Future<bool> removekeyData(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }

  static Future<bool> setkeyData(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(key, value);
  }

  static Future<String> getKeyData(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? "";
  }

  static Future<bool> setUserId(int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Controller().UserId(value);
    stateVariable.userId = value;
    return preferences.setInt("MyId", value);
  }

  static Future<int?> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? id = preferences.getInt("MyId");
    if(id !=null){
      Controller().UserId(id);
      stateVariable.userId = id;
    }
    return id;
  }

  static Future<bool> removeUserId() async {
    Controller().UserId(0);
    stateVariable.userId = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove("MyId");
  }
}

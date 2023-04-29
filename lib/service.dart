import 'package:firebase_chat_demo/bloc/dummy.dart';
import 'package:get_it/get_it.dart';

import 'Storage.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<StateVariable>(StateVariable());
  MyPrefs.getUserId().then((value) => print(value));
// Alternatively you could write it if you don't like global variables
  GetIt.I.registerSingleton<DBRef>(DBRef());
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mvvm/mvvm.dart';
import 'package:firebase_storage/firebase_storage.dart' as FS;
import '../Storage.dart';
import '../main.dart';

class FirebaseDataModal extends ViewModel {
  FirebaseDataModal() {
    //UserId
    MyPrefs.getUserId()
        .then((val) => propertyValue<int>(#userID, initial: val));

    //FirebaseApp
    InitFirebaseDatabase()
        .then((val) => propertyValue<FirebaseApp>(#firebaseapp, initial: val));

    //FirebaseDatabaseReferences
    propertyValue<DatabaseReference>(#ChatListRef);
    propertyValue<DatabaseReference>(#StatusListRef);
    propertyValue<DatabaseReference>(#MessageViewRef);
    propertyValue<DatabaseReference>(#AccountDataRef);

    //FireStorage
    propertyValue<FS.FirebaseStorage>(#FireStore, initial: null);
    start();
  }

  start() {
    //UserId
    MyPrefs.getUserId().then((val) => setValue<int>(#userID, val));

    InitFirebaseDatabase().then((val) {
      // controller.fireStoreInstance(FS.FirebaseStorage.instanceFor(app: val));
      //Firebase
      setValue<FirebaseApp>(#firebaseapp, val);

      //FirebaseDatabaseReferences
      setValue<DatabaseReference>(#ChatListRef,
          FirebaseDatabase(app: val).reference().child('ChatList'));
      setValue<DatabaseReference>(#StatusListRef,
          FirebaseDatabase(app: val).reference().child('StatusList'));
      setValue<DatabaseReference>(#MessageViewRef,
          FirebaseDatabase(app: val).reference().child('messageview'));
      setValue<DatabaseReference>(#AccountDataRef,
          FirebaseDatabase(app: val).reference().child('UserAccount'));

      //FireStorage
      setValue<FS.FirebaseStorage>(
          #FireStore, FS.FirebaseStorage.instanceFor(app: val));
    });
  }
}

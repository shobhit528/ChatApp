import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

CollectionReference users = FirebaseFirestore.instance.collection('Users');

Future<void> addUser(map) {
  // Call the user's CollectionReference to add a new user
  return users
      .add(map)
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}


class FireStoreDb{


  // FirebaseStorage ref=FirebaseStorage.instanceFor(app: val);
}
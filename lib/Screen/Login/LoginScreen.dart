// import 'package:firebase_chat_demo/Component/TextView.dart';
// import 'package:firebase_chat_demo/database/FireStore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mvvm/mvvm.dart';
// import 'package:rounded_loading_button/rounded_loading_button.dart';
//
// import '../Storage.dart';
// import '../main.dart';
// import 'AddChat.dart';
// import 'Home.dart';
// import 'Signup.dart';
//
// final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
//
// class LoginScreen extends View<FirebaseDataModal> {
//   LoginScreen() : super(FirebaseDataModal());
//
//   Map data = {};
//   bool secureText = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text('Flutter Login')),
//         body: ListView(
//           shrinkWrap: true,
//           children: <Widget>[
//             const CircleAvatar(
//               radius: 60,
//               backgroundImage:
//                   NetworkImage("https://picsum.photos/500", scale: 10),
//             ),
//             SizedBox(
//               height: 50,
//             ),
//             InputTextView(
//               labelText: "Number",
//               type: "number",
//               onChange: (value) => data["number"] = value,
//             ),
//              InputTextView(
//               labelText: "IPIN",
//               type: "number",
//               secureText: secureText,
//               // iconClick: () => setState(() {
//               //   secureText = !secureText;
//               // }),
//                iconClick: (){},
//               onChange: (value) => data["password"] = value,
//             ),
//             $.watchFor<FirebaseApp>(#firebaseapp,
//                 builder: $.builder1((app) => Column(
//                       children: [
//                         Container(
//                           margin: EdgeInsets.all(10),
//                           alignment: Alignment.centerRight,
//                           child: SizedBox(
//                             width: 80,
//                             height: 80,
//                             child: RoundedLoadingButton(
//                               width: 80,
//                               height: 80,
//                               borderRadius: 40,
//                               loaderSize: 40,
//                               color: Colors.greenAccent,
//                               child: Icon(Icons.arrow_forward,color: Colors.black38,size: 40,),
//                               controller: _btnController,
//                               onPressed: (){
//                                 FirebaseDatabase(app: app)
//                                     .reference()
//                                     .child('UserAccount/${data["number"]}')
//                                     .get()
//                                     .then((DataSnapshot value) {
//                                   if (value.value != null &&
//                                       value.value["password"] ==
//                                           data["password"]) {
//                                     MyPrefs.setUserId(int.parse(data["number"]))
//                                         .then((value) {
//                                       $.model.setValue<int>(
//                                           #userID, int.parse(data["number"]));
//                                       _btnController.success();
//                                       Get.offAll(() => HomeScreen());
//                                     });
//                                   } else {
//                                     _btnController.error();
//                                     Get.snackbar("Invalid user",
//                                         "Enter Valid Credentials");
//
//                                     Future.delayed(Duration(seconds: 3),(){
//                                       _btnController.reset();
//                                     });
//                                   }
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//
//                         Container(
//                           margin: EdgeInsets.symmetric(vertical: 40,horizontal: 5),
//                           // alignment: Alignment.centerRight,
//                           child: OutlinedButton(
//                               onPressed: () => Get.to(() => Signup()),
//                               style: ButtonStyle(alignment: Alignment.center,animationDuration: Duration(seconds: 1)),
//                               child: TextViewNew("Don't have an account",fontSize: 18,)),
//                         ),
//
//                         Container(
//                           margin: EdgeInsets.symmetric(vertical: 40,horizontal: 5),
//                           alignment: Alignment.centerLeft,
//                           child: OutlinedButton(
//                               onPressed: () => addUser({
//                                 "name": data["number"],
//                                 "number": data["password"]
//                               }),
//                               style: ButtonStyle(alignment: Alignment.center,animationDuration: Duration(seconds: 1)),
//                               child: TextViewNew("Add user to FireStore",fontSize: 18,color: Colors.white,)),
//                         ),
//
//                       ],
//                     ))),
//           ],
//         ));
//   }
// }

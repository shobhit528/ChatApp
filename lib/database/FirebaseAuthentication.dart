import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Component/TextView.dart';
import '../constant/ColorConstant.dart';

sendOTP(
    {String? numberWithCode, Function(String)? verificationCallback}) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: numberWithCode!,
    verificationCompleted: (PhoneAuthCredential credential) {},
    verificationFailed: (FirebaseAuthException e) {
      Get.snackbar(e.code, e.message.toString());
    },
    codeSent: (String verificationId, int? resendToken) =>
        verificationCallback!(verificationId),
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}

signInWithPhoneNumber(
    {String? verificationId, String? otp, Function(bool)? callback}) async {
  try {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp!,
    );

    final User? user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    Get.snackbar("Successfully signed in UID: ${user!.uid}",
        "Successfully signed in UID: ${user.uid}");
    callback!(true);
  } catch (e) {
    Get.snackbar("Failed to sign in: " + e.toString(),
        "Failed to sign in: " + e.toString());
    callback!(false);
  }
}

void showOtpDialog(
    {Function? callback, String? number, String? verificationID}) {
  TextEditingController otpeditingcontroller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  showDialog(
      context: Get.context!,
      builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) => WillPopScope(
                child: new AlertDialog(
                    title: Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Enter OTP",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          new Container(
                            child: Text(
                              "Provide the OTP sent to $number",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: CustomColor().textColor),
                            ),
                            padding: EdgeInsets.all(8),
                          ),
                          new Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
                            child: Form(
                                key: _formKey,
                                child: new TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  autofocus: true,
                                  maxLength: 6,
                                  validator: (value) {
                                    if (value?.trim().length == 0) {
                                      return "Please Enter OTP";
                                    }
                                    if (value!.trim() == "0000" ||
                                        value.trim() == "1234") {
                                      return "Provide valid OTP code";
                                    }
                                    return null;
                                  },
                                  controller: otpeditingcontroller,
                                )),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: TextView(
                            label: "Cancel",
                            type: 1,
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          )),
                      new FlatButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              FocusManager.instance.primaryFocus!.unfocus();
                              signInWithPhoneNumber(
                                  otp: otpeditingcontroller.text.trim(),
                                  verificationId: verificationID,
                                  callback: (bool res) {
                                    callback!(res);
                                    Navigator.of(context).pop();
                                  });
                            } else {
                              Get.snackbar("Provide field not valid",
                                  "Please provide valid field entry");
                            }
                          },
                          child: TextView(
                            label: "Verify",
                            type: 1,
                            color: CustomColor.themeColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ]),
                onWillPop: () async {
                  return Future.value(false);
                }),
          ));
}

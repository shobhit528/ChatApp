import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Screen/Login/CountryListing.dart';
import 'package:firebase_chat_demo/Screen/Login/ProfileInfoScreen.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../Component/Pager.dart';
import '../../Storage.dart';
import '../../Utils/utils.dart';
import '../../bloc/dummy.dart';
import '../../constant/ColorConstant.dart';
import '../../main.dart';

class LoginScreen extends View<FirebaseDataModal> {
  LoginScreen() : super(FirebaseDataModal());

  Map data = {};
  bool isLoading = false;
  String? _verificationId, isError;
  final SmsAutoFill? _autoFill = SmsAutoFill();
  TextEditingController? otpeditingcontroller;
  final TextEditingController CodeController = new TextEditingController();
  late DatabaseReference accountRef =
      $.model.getValue<DatabaseReference>(#AccountDataRef);

  @override
  void init(BuildContext context) {
    super.init(context);
    CountryListApi();
    controller.selectedCountry.listen((value) {
      CodeController.text = value.dialCode!.split("+")[1];
    });

    // _autoFill!.hint.then((value) {
    //   print(value);
    // });

    // _autoFill!.code.listen((event) {
    //   print(event);
    //   showDialog(
    //       context: context,
    //       builder: (context) => new AlertDialog(
    //             title: TextViewNew("$event"),
    //             content: TextViewNew(event.toString()),
    //           ));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextViewNew(Provider.of<AppConst>(context).enterNumber,
              fontWeight: FontWeight.bold, fontSize: 20),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    TextViewNew(
                      Provider.of<AppConst>(context).verifyNumber,
                      fontSize: 16,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Get.to(() => CountryListing()),
                        child: Column(children: [
                          Obx(() => TextViewNew(
                                "${controller.selectedCountry.value.name}",
                                fontSize: 18,
                              )),
                          Divider(
                            thickness: 2,
                          )
                        ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 80,
                                child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Input(
                                          maxLength: 4,
                                          controller: CodeController,
                                          onChange: (val) {
                                            setState(() {
                                              data["code"] = "+" + val.trim();
                                              dynamic sele = controller
                                                  .countryList.value
                                                  .firstWhere((element) =>
                                                      element.dialCode
                                                          .toString() ==
                                                      "+" + val.trim());
                                              controller.selectedCountry(sele);
                                              FocusManager
                                                  .instance.primaryFocus!
                                                  .nextFocus();
                                            });
                                          }),
                                      Positioned(
                                          child: Icon(
                                        Icons.add,
                                        color: CustomColor().iconColor,
                                        size: 15,
                                      ))
                                    ])),
                            SizedBox(width: 20),
                            Flexible(
                                child: SizedBox(
                                    width: 350,
                                    child: Input(
                                        hint: Provider.of<AppConst>(context)
                                            .phoneNumber,
                                        padding: EdgeInsets.all(0),
                                        onChange: (val) {
                                          setState(() {
                                            data["number"] = val.trim();
                                          });
                                        })))
                          ]),
                    ),
                    TextView(
                        label: Provider.of<AppConst>(context).carrierCharge,
                        color: Colors.grey,
                        fontSize: 16),
                  ]),
                  Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: '${data["code"]} ${data["number"]}',
                              verificationCompleted:
                                  (PhoneAuthCredential credential) {
                                // setState(() {
                                //   isLoading = false;
                                // });
                              },
                              verificationFailed: (FirebaseAuthException e) {
                                setState(() {
                                  isError = e.message;
                                  isLoading = false;
                                });
                                Get.snackbar(e.code, e.message.toString());
                              },
                              codeSent:
                                  (String verificationId, int? resendToken) {
                                Future(() {
                                  setState(() {
                                    _verificationId = verificationId;
                                    isLoading = false;
                                  });
                                }).then((value) => showOtpDialog());
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {
                                try {
                                  setState(() => isLoading = false);
                                } catch (e) {}
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              TextViewNew(
                                Provider.of<AppConst>(context)
                                    .next
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )
                            ]),
                            decoration: BoxDecoration(
                                color: CustomColor.themeColor,
                                borderRadius: BorderRadius.circular(5)),
                          ))),
                ]),
            if (isLoading) CircularProgressIndicator()
          ],
        ));
  }

  void signInWithPhoneNumber({Function(bool)? callback}) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpeditingcontroller!.text,
      );

      final User? user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      Get.snackbar("Successfully signed in UID: ${user!.uid}",
          "Successfully signed in UID: ${user.uid}",
          backgroundColor: CustomColor.themeColor);
      callback!(true);
    } catch (e) {
      Get.snackbar("Failed to sign in: " + e.toString(),
          "Failed to sign in: " + e.toString(),
          backgroundColor: CustomColor.themeColor);
      callback!(false);
    }
  }

  void showOtpDialog() async {
    otpeditingcontroller = new TextEditingController();
    final _formKey = GlobalKey<FormState>();
    isLoading = false;

    try {
      otpeditingcontroller!.text != await _autoFill!.hint;
    } catch (e) {

    }
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => WillPopScope(
                  child: new AlertDialog(
                      title: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: <Widget>[
                                Text(
                                  Provider.of<AppConst>(context).enterOtp,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                new Container(
                                  child: Text(
                                    Provider.of<AppConst>(context)
                                        .provideOtp(data["number"]),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: CustomColor().textColor),
                                  ),
                                  padding: EdgeInsets.all(8),
                                ),
                                new Container(
                                  margin: EdgeInsets.all(5),
                                  padding:
                                      EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
                                  child: Form(
                                      key: _formKey,
                                      child: new TextFormField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofocus: true,
                                        maxLength: 6,
                                        validator: (value) {
                                          if (value?.trim().length == 0) {
                                            return Provider.of<AppConst>(
                                                    context)
                                                .otpPlease;
                                          }
                                          if (value!.trim() == "0000" ||
                                              value.trim() == "1234") {
                                            return Provider.of<AppConst>(
                                                    context)
                                                .validOtp;
                                          }
                                          return null;
                                        },
                                        controller: otpeditingcontroller,
                                      )),
                                ),
                              ],
                            ),
                            isLoading
                                ? CircularProgressIndicator(color: Colors.red)
                                : Container(),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: TextView(
                              label: Provider.of<AppConst>(context).cancel,
                              type: 1,
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            )),
                        new FlatButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusManager.instance.primaryFocus!.unfocus();
                                setState(() {
                                  isLoading = true;
                                });
                                signInWithPhoneNumber(callback: (bool res) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Get.back();
                                  NavigateToUserProfileUpdate();
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: TextView(
                              label: Provider.of<AppConst>(context).verify,
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

  NavigateToUserProfileUpdate() {
    setState(() {
      isLoading = true;
    });
    MyPrefs.setUserId(int.parse(data["number"]));
    $.model.setValue<int>(#userID, int.parse(data["number"]));

    accountRef.child(data["number"]).update({
      "number": data["number"],
    }).then((value) {
      setState(() {
        isLoading = false;
      });
      accountRef.child(data["number"]).get().then((value) {
        if (value.value["isRegistered"]) {
          Get.offAll(() => PagerWidget());
        } else {
          Get.offAll(() => ProfileInfoScreen());
        }
      });
    });
  }
}

Widget Input(
    {String? hint,
    maxLength = null,
    TextEditingController? controller,
    Function(String)? onChange,
    padding = const EdgeInsets.only(left: 15)}) {
  return TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ],
    // Only numbers can be ent
    controller: controller,
    maxLength: maxLength,
    onChanged: onChange,
    decoration: InputDecoration(
        hintText: hint,
        alignLabelWithHint: true,
        counterText: "",
        contentPadding: padding),
  );
}

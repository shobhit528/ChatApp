import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Component/customElevatedButton.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../../Utils/utils.dart';
import '../../constant/ColorConstant.dart';
import '../../database/FirebaseAuthentication.dart';
import '../Login/NewLoginScreen.dart';

class Account extends View<FirebaseDataModal> {
  Account() : super(FirebaseDataModal());

  late DatabaseReference messageRef = $.model.getValue(#MessageViewRef);
  late DatabaseReference accountRef = $.model.getValue(#AccountDataRef);
  late DatabaseReference chatListRef = $.model.getValue(#ChatListRef);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(title: Provider.of<AppConst>(context).account),
        body: ListView(children: [
          ListTile(
              leading: Icon(Icons.logout),
              onTap: () => ChangeNumber(),
              title: TextViewNew(Provider.of<AppConst>(context).changeNumber, fontSize: 16)),
          ListTile(
              leading: Icon(Icons.insert_drive_file_outlined),
              onTap: () => RequestAccountInfo(),
              title: TextViewNew(Provider.of<AppConst>(context).requestInfo, fontSize: 16)),
          ListTile(
              leading: Icon(Icons.delete),
              onTap: () => DeleteNumberFromDB(),
              title: TextViewNew(Provider.of<AppConst>(context).deleteMyAccount, fontSize: 16)),
        ]));
  }

  ChangeNumber() {
    Navigator.of(Get.context!).push(new MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBarView(title: Provider.of<AppConst>(context).changeNumber),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: ListView(children: [
                Container(
                  height: 120,
                  width: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/change.jpeg',
                    height: 120,
                    width: 120,
                    cacheWidth: 120,
                    cacheHeight: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: TextViewNew(
                        Provider.of<AppConst>(context).migrateAccount,
                        textAlign: TextAlign.center,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: TextViewNew(
                      Provider.of<AppConst>(context).verifyNewNumber,
                      textAlign: TextAlign.center,
                      color: Colors.grey,
                    )),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: TextViewNew(
                      Provider.of<AppConst>(context).changeOldPhone,
                      textAlign: TextAlign.center,
                      color: Colors.grey,
                    )),
              ])),
              Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: OutlinedButton(
                      onPressed: () => VerifyNumber(),
                      style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor:
                              MaterialStateProperty.all(CustomColor.themeColor),
                          animationDuration: Duration(seconds: 1)),
                      child: TextViewNew(
                        Provider.of<AppConst>(context).next.toUpperCase(),
                        fontSize: 18,
                        color: Colors.white,
                      ))),
            ]),
      ),
    ));
  }

  VerifyNumber() {
    TextEditingController oldNumberController = new TextEditingController();
    TextEditingController newNumberController = new TextEditingController();
    RxString oldcode = "".obs, newcode = "".obs;
    oldNumberController.text = controller.UserProfile["number"];
    Navigator.of(Get.context!).push(new MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBarView(title: Provider.of<AppConst>(context).needtoVerify),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextViewNew(
                                  Provider.of<AppConst>(context).enterOldNumber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 80,
                                          child: Stack(
                                              alignment: Alignment.centerLeft,
                                              children: [
                                                Input(
                                                    maxLength: 4,
                                                    onChange: (val) {
                                                      oldcode(val.trim());
                                                      // FocusManager.instance.primaryFocus!.nextFocus();
                                                    }),
                                                Positioned(
                                                    child: Icon(
                                                  Icons.add,
                                                  color:
                                                      CustomColor().iconColor,
                                                  size: 15,
                                                ))
                                              ])),
                                      SizedBox(width: 20),
                                      Flexible(
                                          child: SizedBox(
                                              width: 350,
                                              child: Input(
                                                hint: Provider.of<AppConst>(context).phoneNumber,
                                                enabled: false,
                                                controller: oldNumberController,
                                                padding: EdgeInsets.all(0),
                                              )))
                                    ]),
                                SizedBox(
                                  height: 50,
                                ),
                                TextViewNew(
                                  Provider.of<AppConst>(context).enterNewNumber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 80,
                                          child: Stack(
                                              alignment: Alignment.centerLeft,
                                              children: [
                                                Input(
                                                    maxLength: 4,
                                                    onChange: (val) {
                                                      newcode(val.trim());
                                                      // FocusManager.instance.primaryFocus!.nextFocus();
                                                    }),
                                                Positioned(
                                                    child: Icon(
                                                  Icons.add,
                                                  color:
                                                      CustomColor().iconColor,
                                                  size: 15,
                                                ))
                                              ])),
                                      SizedBox(width: 20),
                                      Flexible(
                                          child: SizedBox(
                                              width: 350,
                                              child: Input(
                                                hint: Provider.of<AppConst>(context).phoneNumber,
                                                padding: EdgeInsets.all(0),
                                                controller: newNumberController,
                                              )))
                                    ]),
                              ]))),
                  Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => new AlertDialog(
                                      title: Text(Provider.of<AppConst>(context).proceedToVerify),
                                      content: Text(
                                          Provider.of<AppConst>(context).clickproceedToVerify
                                          ),
                                      actions: [
                                        OutlinedButton(
                                            onPressed: () => Get.back(),
                                            style: ButtonStyle(
                                                alignment: Alignment.center),
                                            child: Text(Provider.of<AppConst>(context).cancel)),
                                        OutlinedButton(
                                            onPressed: () => sendOTP(
                                                numberWithCode: "+" +
                                                    newcode.string +
                                                    newNumberController.text,
                                                verificationCallback:
                                                    (String vId) {
                                                  Get.back();
                                                  showOtpDialog(
                                                      number: "+" +
                                                          newcode.string +
                                                          newNumberController
                                                              .text,
                                                      verificationID: vId,
                                                      callback: (bool status) {
                                                        if (status) {
                                                          UpdateDatabaseNumber(
                                                              newNumberId: int.parse(
                                                                  newNumberController
                                                                      .text));
                                                          Get.back();
                                                        } else {
                                                          Get.snackbar(
                                                              "Something went wrong",
                                                              "Some error occured during verification,please try again");
                                                          Get.back();
                                                        }
                                                      });
                                                }),
                                            style: ButtonStyle(
                                                alignment: Alignment.center),
                                            child: Text(Provider.of<AppConst>(context).proceed))
                                      ],
                                    ));
                          },
                          style: ButtonStyle(
                              alignment: Alignment.center,
                              backgroundColor: MaterialStateProperty.all(
                                  CustomColor.themeColor),
                              animationDuration: Duration(seconds: 1)),
                          child: TextViewNew(
                            Provider.of<AppConst>(context).next.toUpperCase(),
                            fontSize: 18,
                            color: Colors.white,
                          ))),
                ]))));
  }

  UpdateDatabaseNumber({int? newNumberId}) async {
    int? userId = await MyPrefs.getUserId();

    await chatListRef.get().then((value) {
      value.value.forEach((k, v) async {
        Map<String, dynamic> res = new Map<String, dynamic>.from(v);
        if (res["users"].contains(userId)) {
          List arr = res["users"].toList();
          arr.remove(userId);
          arr.add(newNumberId);
          await chatListRef.child(k).update({"users": arr});
        }
        if (res["senderId"] == userId) {
          await chatListRef.child(k).update({"senderId": newNumberId});
        }
      });
    });
    await messageRef.get().then((value) {
      value.value.forEach((k, v) async {
        Map<String, dynamic> res = new Map<String, dynamic>.from(v);
        if (res["users"].contains(userId)) {
          List arr = res["users"].toList();
          arr.remove(userId);
          arr.add(newNumberId);
          await messageRef.child(k).update({"users": arr});
        }
        if (res["senderId"] == userId) {
          await messageRef.child(k).update({"senderId": newNumberId});
        }
      });
    });
    await accountRef.get().then((DataSnapshot value) {
      value.value.forEach((k, v) {
        if (k.toString() == userId.toString()) {
          accountRef.update({newNumberId.toString(): v});
          accountRef
              .child(newNumberId.toString())
              .update({"number": newNumberId.toString()});
          accountRef.child(userId.toString()).remove();
        }
      });
    });
    await MyPrefs.setUserId(newNumberId!);
  }

  RequestAccountInfo() {
// to be viewed in original app
  }

  DeleteNumberFromDB() async {
    int? userId = await MyPrefs.getUserId();
    CountryListApi();
    TextEditingController numberController = new TextEditingController();
    TextEditingController codeController = new TextEditingController();

    RxBool isShowing = false.obs, isVerified = false.obs;
    // codeController.addListener(() {
    //   Country? data = controller.countryList.value
    //       .firstWhere((element) => codeController.text == element.dialCode);
    //   print(data);
    // });
    numberController
        .addListener(() => isShowing(!numberController.text.isEmpty));
    Navigator.of(Get.context!).push(new MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBarView(title: Provider.of<AppConst>(context).deleteAccount),
            body: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextViewNew(
                      Provider.of<AppConst>(context).enterNewNumber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                          width: 80,
                          child:
                              Stack(alignment: Alignment.centerLeft, children: [
                            Input(maxLength: 4, controller: codeController),
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
                                hint: Provider.of<AppConst>(context).phoneNumber,
                                controller: numberController,
                                padding: EdgeInsets.all(0),
                              )))
                    ]),
                    Obx(() => isShowing.isTrue
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: OutlinedButton(
                                onPressed: () => sendOTP(
                                    numberWithCode: "+" +
                                        codeController.text +
                                        numberController.text,
                                    verificationCallback: (vId) {
                                      showOtpDialog(
                                          number: "+" +
                                              codeController.text +
                                              numberController.text,
                                          verificationID: vId,
                                          callback: (bool status) {
                                            if (status) {
                                              isVerified(status);
                                              isShowing(false);
                                            }
                                          });
                                    }),
                                style: ButtonStyle(
                                    alignment: Alignment.center,
                                    backgroundColor: MaterialStateProperty.all(
                                        CustomColor.themeColor),
                                    animationDuration: Duration(seconds: 1)),
                                child: TextViewNew(
                                    Provider.of<AppConst>(context).sendOtp.toUpperCase(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                )))
                        : SizedBox()),
                    SizedBox(
                      height: 100,
                    ),
                    Obx(() => isVerified.isFalse
                        ? SizedBox()
                        : CustomButtonElevated(
                            buttontext: Provider.of<AppConst>(context).clickToDelete,
                            onPress: (_) {
                              accountRef
                                  .child(userId.toString())
                                  .remove()
                                  .whenComplete(
                                      () => Get.offAll(() => LoginScreen()));
                            },
                          ))
                  ]),
            ))));
  }
}

Widget Input(
    {String? hint,
    maxLength = null,
    TextEditingController? controller,
    enabled = true,
    Function(String)? onChange,
    padding = const EdgeInsets.only(left: 15)}) {
  return TextFormField(
    enabled: enabled,
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

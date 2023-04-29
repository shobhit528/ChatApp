import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Component/AppBarView.dart';
import '../../Component/TextView.dart';
import '../../Utils/utils.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(title:Provider.of<AppConst>(context). help),
        body: ListView(children: [
          ListTile(
              leading: Icon(Icons.help_outline),
              onTap: () => UrlLauncher("https://www.google.com"),
              title: TextViewNew(Provider.of<AppConst>(context).helpCenter, fontSize: 16)),
          ListTile(
              leading: Icon(Icons.insert_drive_file_outlined),
              onTap: () {
                TextEditingController textcontroller =
                    new TextEditingController();
                Navigator.of(Get.context!).push(new MaterialPageRoute(
                    builder: (context) => Scaffold(
                        appBar: AppBarView(title:Provider.of<AppConst>(context).contactUs),
                        body: Column(
                            children: [
                              Column(children: [
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: Input(
                                        controller: textcontroller,
                                        maxLines: 5,
                                        padding: EdgeInsets.all(5),
                                        hint: Provider.of<AppConst>(context).howToHelp),
                                    color: Colors.black45),
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(children: [
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            TextViewNew(
                                                Provider.of<AppConst>(context).deviceIfo),
                                            TextViewNew(
                                                Provider.of<AppConst>(context).techDetails,
                                                fontWeight: FontWeight.w300),
                                          ])),
                                      Checkbox(
                                          value: true,
                                          onChanged: (_) => print(_))
                                    ])),
                              ]),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextViewNew(
                                          Provider.of<AppConst>(context).respondInChat),
                                      flex: 3,
                                    ),
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                              alignment: Alignment.center,
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blueGrey),
                                              animationDuration:
                                                  Duration(seconds: 1)),
                                          child: TextViewNew(
                                            Provider.of<AppConst>(context).next.toUpperCase(),
                                            fontSize: 16,
                                            color: Colors.white,
                                          )),
                                      flex: 1,
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                ),
                              )
                            ],
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween))));
              },
              title: TextViewNew(Provider.of<AppConst>(context).contactUs, fontSize: 16)),
          ListTile(
              leading: Icon(Icons.file_copy_outlined),
              onTap: () => UrlLauncher("https://www.google.com"),
              title: TextViewNew(Provider.of<AppConst>(context).termPolicy, fontSize: 16)),
          ListTile(
              leading: Icon(Icons.info_outline),
              onTap: () {
                Navigator.of(Get.context!).push(new MaterialPageRoute(
                    builder: (context) => Scaffold(
                            body: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                   image:  AssetImage("assets/background.png"),
                                  fit: BoxFit.cover,
                                )
                              ),
                          alignment: Alignment.center,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextViewNew(Provider.of<AppConst>(context).appMessanger,
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                Obx(()=>TextViewNew("Version ${controller.AppInfo["buildNumber"]}.${controller.AppInfo["version"]}",
                                    fontSize: 18, color: Colors.grey)),
                                Image.asset(
                                  'assets/appicon.jpg',
                                  height: 100,
                                  width: 100,
                                ),
                                TextViewNew(Provider.of<AppConst>(context).onward,
                                    fontSize: 18, color: Colors.grey,fontWeight: FontWeight.bold,),
                              ]),
                        ))));
              },
              title: TextViewNew(Provider.of<AppConst>(context).appInfo, fontSize: 16)),
        ]));
  }
}

Widget Input(
    {String? hint,
    maxLength = null,
    TextEditingController? controller,
    Function(String)? onChange,
    int maxLines = 1,
    padding = const EdgeInsets.only(left: 15)}) {
  return TextFormField(
    keyboardType: TextInputType.multiline,
    inputFormatters: <TextInputFormatter>[
      // FilteringTextInputFormatter.allow(filterPattern)
    ],
    // Only numbers can be ent
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    onChanged: onChange,
    decoration: InputDecoration(
        hintText: hint,
        alignLabelWithHint: true,
        counterText: "",
        contentPadding: padding),
  );
}

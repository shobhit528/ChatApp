import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/ContactModal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contact.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Utils/utils.dart';
import '../constant/appConstant.dart';
import '../main.dart';

class ContactList extends StatelessWidget {
  ContactList({this.callback});

  Function(ContactModal)? callback;

  @override
  Widget build(BuildContext context) {
    getContactPermission().then((value) => FetchContactList());

    return Obx(() => ListView(
        shrinkWrap: true,
        children: controller.Contactlist.value
            .map<Widget>((e) => GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => new AlertDialog(
                              title: TextViewNew(Provider.of<AppConst>(context).shareContact,fontWeight: FontWeight.bold,fontSize: 16),
                              content: TextViewNew(Provider.of<AppConst>(context).sendContact),
                              actions: [
                                OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: TextViewNew(Provider.of<AppConst>(context).cancel)),
                                OutlinedButton(
                                    onPressed: () => callback!(e),
                                    child: TextViewNew(Provider.of<AppConst>(context).send))
                              ])),
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: new NetworkImage(
                                      "https://picsum.photos/500",
                                      scale: 10),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        e.number!,
                                      )
                                    ],
                                  ),
                                  flex: 2),
                              Expanded(flex: 1, child: SizedBox())
                            ],
                          )),
                      Divider(
                        height: 2,
                        thickness: 1,
                      )
                    ],
                  ),
                ))
            .toList()));
  }
}

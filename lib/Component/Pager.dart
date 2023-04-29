// import 'package:firebase_chat_demo/Screen/ChatScreen.dart';
// import 'package:firebase_chat_demo/Screen/Login/NewLoginScreen.dart';
// import 'package:firebase_chat_demo/Screen/Login/ProfileInfoScreen.dart';
// import 'package:firebase_chat_demo/Screen/StatusScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'AppBarView.dart';
//
// RxInt i = 0.obs;
//
//
// class PagerWidget extends StatelessWidget {
//   PagerWidget({Key? key, this.callback});
//   final Function(int)? callback;
//
//   CreateHeader(int i) {
//     switch (i) {
//       case 0:
//         return "Chats";
//       case 1:
//         return "Status";
//       default:
//         return "Chats";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final PageController controller = PageController();
//     return Obx(() => Scaffold(
//         appBar: AppBarView(title: CreateHeader(i.value)),
//         body: PageView(
//           controller: controller,
//           onPageChanged: (value) => i(value),
//           children: <Widget>[
//             KeepAlivePage(child: ChatScreen(),key: Key("%"),),
//             KeepAlivePage(child: StatusScreen(),key: Key("#"),),
//           ],
//         )));
//     return PageView(
//       controller: controller,
//       onPageChanged: callback,
//       children: <Widget>[
//         KeepAlivePage(child: ChatScreen()),
//         KeepAlivePage(child: StatusScreen())
//       ],
//     );
//   }
// }
//
// class KeepAlivePage extends StatefulWidget {
//   KeepAlivePage({
//     Key? key,
//     @required this.child,
//   }) : super(key: key);
//
//   final Widget? child;
//
//   @override
//   _KeepAlivePageState createState() => _KeepAlivePageState();
// }
//
// class _KeepAlivePageState extends State<KeepAlivePage>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     /// Dont't forget this
//     super.build(context);
//
//     return widget.child!;
//   }
//
//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }

import 'dart:io';

import 'package:firebase_chat_demo/Screen/ChatScreen.dart';
import 'package:firebase_chat_demo/Screen/StatusScreen.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvvm/mvvm.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
import 'package:provider/provider.dart';
import '../Utils/utils.dart';
import '../bloc/dummy.dart';
import '../main.dart';
import 'AppBarView.dart';
import 'TextView.dart';

class PagerWidget extends View<FirebaseDataModal> with WidgetsBindingObserver {
  Brightness? _brightness;

  PagerWidget({Key? key, this.callback}) : super(FirebaseDataModal());
  RxInt currentIndex = 0.obs;
  final Function(int)? callback;
  final PageController pageController = PageController(initialPage: 0);

  @override
  void init(BuildContext context) {
    WidgetsBinding.instance?.addObserver(this);
    _brightness = WidgetsBinding.instance?.window.platformBrightness;
    getContactPermission().then((value) => FetchContactList());
    super.init(context);
    currentIndex.listen((value) {
      if (currentIndex.value == value)
        pageController.animateToPage(value,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    try {
      setState(() {
        _brightness = WidgetsBinding.instance?.window.platformBrightness;
        print(_brightness);
        controller.DarkMode(_brightness == Brightness.dark);
        main();
      });
    } catch (er) {}

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBarView(title: AppConst.AppName),
            body: Column(children: [
              Obx(() => Row(
                  children:
                      [0, 1, 2].map<Widget>((e) => RowHeader(e)).toList())),
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (value) => currentIndex(value),
                  children: <Widget>[
                    $.watchFor<DatabaseReference>(#ChatListRef,
                        builder: $.builder1((ChatListing) => ChatListing == null
                            ? Container(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )
                            : KeepAlivePage(
                                child: ChatScreen(),
                                key: Key("%"),
                              ))),
                    $.watchFor<DatabaseReference>(#StatusListRef,
                        builder:
                            $.builder1((StatusListing) => StatusListing == null
                                ? Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  )
                                : KeepAlivePage(
                                    child: StatusScreen(),
                                    key: Key("#"),
                                  ))),
                  ],
                ),
              )
            ])),
        onWillPop: () async {
          if (currentIndex.value != 0) {
            pageController.animateToPage(0,
                duration: Duration(seconds: 1), curve: Curves.easeInOut);
          } else {
            exit(0);
          }
          return false;
        });
  }

  Widget RowHeader(int e) {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(top: 7),
          color: controller.isDarkMode
              ? Colors.transparent
              : CustomColor.themeColor,
          child: GestureDetector(
            onTap: () => currentIndex(e),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: TextView(
                      label: CreateHeader(e),
                      fontWeight: FontWeight.bold,
                      type: 1,
                      color: currentIndex.value == e
                          ? CustomColor().tabbarColor
                          : Colors.grey,
                    ),
                  ),
                  Divider(
                      thickness: 3,
                      color: currentIndex.value == e
                          ? CustomColor().tabbarColor
                          : Colors.transparent)
                ]),
            behavior: HitTestBehavior.translucent,
          )),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  KeepAlivePage({
    Key? key,
    @required this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return widget.child!;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

CreateHeader(int i) {
  switch (i) {
    case 0:
      return Provider.of<AppConst>(Get.context!).chats.toUpperCase();
    case 1:
      return Provider.of<AppConst>(Get.context!).status.toUpperCase();
    case 2:
      return Provider.of<AppConst>(Get.context!).comingSoon.toUpperCase();
    default:
      return Provider.of<AppConst>(Get.context!).chats.toUpperCase();
  }
}

class HeaderTab {
  String? Name;
  int? index;
  Function? onTap;

  HeaderTab({this.Name, this.index, this.onTap});
}

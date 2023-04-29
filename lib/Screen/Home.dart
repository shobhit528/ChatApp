import 'package:firebase_chat_demo/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../Component/AppBarView.dart';
import '../Component/TextView.dart';
import 'ChatScreen.dart';
import 'StatusScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(title: "Firebase Chat App"),
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < 0) {
              setState(() {
                currentIndex =  1;
              });
            } else if (details.delta.dx > 0) {
              setState(() {
                currentIndex = 0;
              });
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 0;
                        });
                      },
                      child: Column(children: [
                        TextView(
                          label: "Chats",
                          color: currentIndex == 0 ? Colors.white : Colors.grey,
                        ),
                        Divider(
                            thickness: 2,
                            color: currentIndex == 0
                                ? Colors.white
                                : Colors.transparent)
                      ]),
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          currentIndex = 1;
                        });
                      },
                      child: Column(
                        children: [
                          TextView(
                              label: "Status",
                              color: currentIndex == 1
                                  ? Colors.white
                                  : Colors.grey),
                          Divider(
                              thickness: 2,
                              color: currentIndex == 1
                                  ? Colors.white
                                  : Colors.transparent)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          currentIndex = 2;
                        });
                      },
                      child: Column(
                        children: [
                          TextView(
                            label: "Coming Soon",
                            color:
                                currentIndex == 2 ? Colors.white : Colors.grey,
                          ),
                          Divider(
                              thickness: 2,
                              color: currentIndex == 2
                                  ? Colors.white
                                  : Colors.transparent)
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (currentIndex == 0) Expanded(child: ChatScreen(), flex: 1),
              if (currentIndex == 1) Expanded(child: StatusScreen(), flex: 1),
            ],
          ),
        ));
  }
}

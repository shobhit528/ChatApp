import 'dart:async';
import 'dart:convert';

import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';

import 'ChatDetails/ChatDetailsFunction.dart';

final controller = StoryController();

class StatusViewer extends StatelessWidget {
  StatusViewer({this.items});

  dynamic items;
  late List<StoryItem>? storyItems = AddItem(items);


  AddItem(items) {

    List<StoryItem> arr = [];
    items.forEach((item){
      if(item["type"]=="image"){
        arr.add(StoryItem.pageImage(controller: controller, url:item["content"],caption: item["caption"]??""));
      }else{

      }
    });
    // [
    //   StoryItem.text(title: 'ABC', backgroundColor: Colors.red),
    //   StoryItem.pageImage(controller: controller, url: '',),
    //   StoryItem.pageImage(controller: controller, url: ''),
    // ];

    return arr;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppbarnoAction(),
          body: StoryView(
              storyItems: storyItems!,
              controller: controller,
              // pass controller here too
              repeat: false,
              // should the stories be slid forever
              onStoryShow: (s) {
                // notifyServer(s)
              },
              onComplete: () {
                Get.back();
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              } // To disable vertical swipe gestures, ignore this parameter.
            // Preferrably for inline story view.
          ),
        ));
  }
}


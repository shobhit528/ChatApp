import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Component/TextView.dart';
import 'package:firebase_chat_demo/Modal/CountryCode.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/ColorConstant.dart';

class CountryListing extends StatelessWidget {
  CountryListing();

  @override
  Widget build(BuildContext context) {
    final _itemExtent = 60.0;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
          title: "Choose a country",
          AppBarActions: Container(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.search),
            ),
          )),
      body: CustomScrollView(
        controller: ScrollController(initialScrollOffset: 0),
        slivers: [
          Obx(() => SliverFixedExtentList(
                itemExtent: _itemExtent,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                    title: CountryRow(controller.countryList.value[index]),
                  ),
                  childCount: controller.countryList.length,
                ),
              )),
        ],
      ),
    ));
  }
}

Widget CountryRow(Country? element) {

  return Obx(()=>new Card(
    elevation: 1,
    color:element!.code==controller.selectedCountry.value.code?
    controller.isDarkMode ? Colors.cyan : Colors.blueGrey
        : null,
    child: ListTile(
      onTap: () {
        controller.selectedCountry(element);
        Get.back();
      },
      leading: getImage(element.image!),
      title: TextViewNew(
        element.name!,
        fontSize: 16,
        color: CustomColor().textColor,
        fontWeight: FontWeight.bold,
      ),
      trailing: TextViewNew(
        element.dialCode!,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  ));
}

Widget getImage(String image) {
  try {
    return Image.asset(
      image,
      height: 40,
      width: 40,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/country/earth.png',
          fit: BoxFit.cover,
          height: 40,
          width: 40,
        );
      },
    );
  } catch (e) {
    return Image.asset('assets/country/earth.png', scale: 3);
  }
}

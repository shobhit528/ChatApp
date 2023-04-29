import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressDialog {
  OverlayEntry? currentLoader;
  bool isShowing = false;

  void show(BuildContext context, {color}) {
    currentLoader = new OverlayEntry(
      builder: (context) => GestureDetector(
        child: Container(
          color: Colors.transparent,
          width: Get.width,
          height: Get.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[getCircularProgressIndicator(color: color)],
            ),
          ),
        ),
        onTap: () {
          // do nothing
        },
      ),
    );
    if (!isShowing) Overlay.of(Get.context!)!.insert(currentLoader!);
    isShowing = true;
  }

  void hide() {
    if (currentLoader != null) {
      currentLoader?.remove();
      isShowing = false;
      currentLoader = null;
    }
  }

  getCircularProgressIndicator({double? height, double? width, color}) {
    if (height == null) {
      height = 40.0;
    }
    if (width == null) {
      width = 200.0;
    }
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
      child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(color),
                    ),
                    Text(
                      "Loading....",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                height: height,
                width: width,
              ))),
    );
  }

  getErrorWidget() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: Text("Oops! Something went wrong.", textScaleFactor: 1.0),
        height: 40.0,
        width: 40.0,
      ),
    );
  }
}

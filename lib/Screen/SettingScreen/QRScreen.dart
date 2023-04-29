import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/bloc/dummy.dart';
import 'package:firebase_chat_demo/constant/appConstant.dart';
import 'package:firebase_chat_demo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';
import 'package:screenshot/screenshot.dart';

import '../../Component/CircularImageView.dart';
import '../../Component/Pager.dart';
import '../../Component/PagerComponent.dart';
import '../../Component/TextView.dart';
import '../../Utils/utils.dart';
import '../../constant/ColorConstant.dart';

class QRClass extends StatelessWidget {
  RxInt index = 0.obs;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarView(
            title: Provider.of<AppConst>(context).qrCode,
            CustomWidget: Obx(() => index.value == 0
                ? GestureDetector(
                    child: Icon(Icons.save),
                    onTap: () async {
                      dynamic image = await screenshotController.capture();
                      if (image != null) await SaveImage(image);
                    },
                    behavior: HitTestBehavior.translucent,
                  )
                : SizedBox())),
        body: PagerComponent(
          list: [
            KeepAlivePage(
                key: Key("%"),
                child: MyQrClass(screenshotController: screenshotController)),
            QRCodeScanner()
          ],
          indexListener: (int? i) => index(i),
        ));
  }

  Future<String> SaveImage(Uint8List? bytes) async {
    final storage = await Permission.storage.request();
    final result = await ImageGallerySaver.saveImage(bytes!,
        name: controller.UserProfile["user"].toString().trim() + "-Qr");
    Get.snackbar("Saved", Provider.of<AppConst>(Get.context!).imageSaved);
    return result['filePath'];
  }
}

class MyQrClass extends StatelessWidget {
  MyQrClass({this.screenshotController});

  ScreenshotController? screenshotController;

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Screenshot(
          controller: screenshotController!,
          child: Center(
            child: Container(
              margin: EdgeInsets.only(left: 35, right: 35, top: 10),
              padding: EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(10)),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Obx(() => ImageViewCircle(
                      url: controller.UserProfile.value["avatar"] ?? "")),
                  Align(
                      alignment: Alignment.center,
                      child: Obx(() => TextViewNew(
                          controller.UserProfile.value["user"],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.left))),
                  SizedBox(height: 10),
                  Align(
                      alignment: Alignment.center,
                      child: TextViewNew("${AppConst.AppName} Contact",
                          fontSize: 16, textAlign: TextAlign.left)),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: QrImage(
                        data: jsonEncode(controller.UserProfile),
                        version: QrVersions.auto,
                        size: 200,
                        gapless: true,
                        embeddedImage: AssetImage('assets/appicon.jpg'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(40, 40),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.all(10),
        child: TextViewNew(
          Provider.of<AppConst>(context).privateQR,
          textAlign: TextAlign.center,
          fontSize: 16,
        ),
      )
    ]);
  }
}

class QRCodeScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => QRViewState();
}

class QRViewState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  Map<String, dynamic>? response;
  QRViewController? controller;
  RxBool isFlashEnable = false.obs;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Stack(children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderRadius: 5,
                    borderColor: CustomColor.themeColor,
                    borderWidth: 10,
                    overlayColor: Color.fromRGBO(0, 0, 0, 0.6)),
              ),
              Positioned(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Utils.imgFromGallery((image) async {
                      String? result = await Scan.parse(image.path);
                      setState(() {
                        response = jsonDecode(result!);
                      });
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1, color: Colors.white)),
                    child: Icon(Icons.image),
                  ),
                ),
                left: 10,
                bottom: 10,
              ),
              Positioned(
                child: Obx(() => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        isFlashEnable(!isFlashEnable.value);
                        controller!.toggleFlash();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1, color: Colors.white)),
                        child: Icon(isFlashEnable.isTrue
                            ? Icons.flash_off
                            : Icons.flash_on),
                      ),
                    )),
                right: 10,
                bottom: 10,
              )
            ]),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (response == null)
                  ? TextView(
                      label: Provider.of<AppConst>(context).scanCode,
                      color: CustomColor().textColor,
                      type: 1,
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: CircleAvatar(
                                  radius: 30,
                                  child: ClipOval(
                                    child: Image.network(
                                      response!["avatar"].toString(),
                                    ),
                                  ),
                                ),
                                flex: 1),
                            Expanded(
                              child: ListView(shrinkWrap: true, children: [
                                TextViewNew(response!["user"],
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center),
                                TextViewNew(
                                  response!["number"],
                                  fontSize: 16,
                                  textAlign: TextAlign.center,
                                ),
                              ]),
                              flex: 3,
                            ),
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () {
                                      if (response!["isRegistered"]) {
                                        DatabaseFunction()
                                            .InitChatListMessage();
                                      } else {
                                        String url =
                                            "sms:${response!["number"]}?body=Let's chat on ${AppConst.AppName}! It's simple, fast and secure app. we can use to message each and call(coming soon).";
                                        UrlLauncher(url);
                                      }
                                    },
                                    style: ButtonStyle(
                                        alignment: Alignment.center,
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueGrey),
                                        animationDuration:
                                            Duration(seconds: 1)),
                                    child: TextViewNew(
                                      Provider.of<AppConst>(context)
                                          .inviteMessage(
                                              response!["isRegistered"]),
                                      fontSize: 16,
                                      color: Colors.white,
                                    )),
                                flex: 2)
                          ]),
                    ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        response = jsonDecode(scanData.code!);
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

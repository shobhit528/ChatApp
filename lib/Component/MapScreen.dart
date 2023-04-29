import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvvm/mvvm.dart';
import 'package:provider/provider.dart';

import '../Storage.dart';
import '../constant/appConstant.dart';
import '../main.dart';
import 'package:firebase_chat_demo/Modal/firebaseDataModal.dart';
class MapScreen extends View<FirebaseDataModal> {
  MapScreen([this.Id]) : super(FirebaseDataModal());

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(25.996291, 79.389092), zoom: 10);
  GoogleMapController? mapController;
  int? Userid, Id;

  RxBool locationFetching = true.obs;

  @override
  void init(BuildContext context) {
    MyPrefs.getUserId().then((value) => Userid = value);
    super.init(context);
    late DatabaseReference account;
    Future(() {
      account = $.model.getValue(#AccountDataRef);
    }).then((v) {
      if (Id != null && locationFetching.value) {
        try {
          account.child(Id.toString()).get().then((DataSnapshot value) {
            Map<String, dynamic> data =
                new Map<String, dynamic>.from(value.value["liveSharing"]);
            if (data["$Userid"] == null) {
              locationFetching(false);
              CreateMarker(
                  LatLng(value.value["latitude"], value.value["longitude"]),
                  title: Provider.of<AppConst>(context).lastLocation,
                  address: Provider.of<AppConst>(context).stoppedLocation);
            } else if (data["$Userid"]["isSharing"]) {
              CreateMarker(
                  LatLng(value.value["latitude"], value.value["longitude"]),
                  title: Provider.of<AppConst>(context).activeLocation,
                  address: Provider.of<AppConst>(context).activlyLocation);
            } else if (!data["$Userid"]["isSharing"]) {
              locationFetching(false);
              CreateMarker(
                  LatLng(value.value["latitude"], value.value["longitude"]),
                  title: Provider.of<AppConst>(context).lastLocation,
                  address: Provider.of<AppConst>(context).stoppedLocation);
              showDialog(
                context: context,
                builder: (context) => new WillPopScope(
                  child: new AlertDialog(
                    title: Text(Provider.of<AppConst>(context).stoppedLocation),
                    content: Text(Provider.of<AppConst>(context).stopFromSender),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Get.back(),
                          style: ButtonStyle(alignment: Alignment.center),
                          child: Text(Provider.of<AppConst>(context).keepOpen)),
                      OutlinedButton(
                          onPressed: (){
                            Get.back();
                            Get.back();
                          },
                          style: ButtonStyle(alignment: Alignment.center),
                          child: Text(Provider.of<AppConst>(context).goBack))

                    ],
                  ),
                  onWillPop: () async{

                     return false;
                  },
                ),
              );
            } else {
              CreateMarker(
                  LatLng(value.value["latitude"], value.value["longitude"]),
                  title: Provider.of<AppConst>(context).lastLocation,
                  address: Provider.of<AppConst>(context).stoppedLocation);
            }
            // if (Userid != Id)
          });
        } catch (e) {}
      }
    });
  }

  CreateMarker(LatLng latLng, {String? title, String? address}) {
    getBytesFromAsset('assets/navigate.png', 100).then((markerIcon) {
      var marker = Marker(
        markerId: MarkerId('place_name'),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        consumeTapEvents: true,
        infoWindow: InfoWindow(
          title: title!,
          snippet: address!,
        ),
      );

      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 20)));
      try {
        setState(() {
          markers[MarkerId('place_name')] = marker;
        });
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new GoogleMap(
        markers: markers.values.toSet(),
        initialCameraPosition: _initialLocation,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

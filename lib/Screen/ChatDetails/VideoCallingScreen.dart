import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:firebase_chat_demo/Component/AppBarView.dart';
import 'package:firebase_chat_demo/Storage.dart';
import 'package:firebase_chat_demo/constant/ColorConstant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constant/appConstant.dart';

/// MultiChannel Example
class VideoCallingApp extends StatefulWidget {
  VideoCallingApp(
      {this.isCallAudio = true, this.CallerId, this.uid, this.callback});

  bool? isCallAudio;
  int? uid;
  dynamic CallerId;
  Function(dynamic)? callback;

  @override
  State<StatefulWidget> createState() => _State(isCallAudio: isCallAudio);
}

class _State extends State<VideoCallingApp> {
  _State({this.isCallAudio = true});

  bool? isCallAudio;

  late final RtcEngine _engine;
  String appId = "c8e15c4f4ca846f49a465a30d85c4e53";
  String channelId = "firstcall";
  String token =
      "006c8e15c4f4ca846f49a465a30d85c4e53IAAm9xrZZMfOMnnDzh0XKD0xyQP8EKUfbtxgBs71leAP/lBfDREAAAAAEAClV51HAtUdYgEAAQAC1R1i";

  bool isJoined = false,
      switchCamera = true,
      switchRender = true,
      isNotMuted = true,
      isSpeaker = true,
      isVideoRequested = false;
  List<int> remoteUid = [];
  bool _isRenderSurfaceView = false;
  int? userId;

  @override
  void initState() {
    super.initState();
    MyPrefs.getUserId().then((value) => setState(() => userId = value));
    this._initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    this._addListeners();

    if (isCallAudio!)
      await _engine.enableAudio();
    else
      await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _joinChannel();
  }

  _addListeners() {
    _engine.setEventHandler(RtcEngineEventHandler(
      warning: (warningCode) {
        print('warning ${warningCode}');
      },
      error: (errorCode) {
        print('error ${errorCode}');
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        print('joinChannelSuccess ${channel} ${uid} ${elapsed}');
        setState(() {
          isJoined = true;
        });
      },
      userJoined: (uid, elapsed) {
        print('userJoined  ${uid} ${elapsed}');
        setState(() {
          remoteUid.add(uid);
        });
      },
      userOffline: (uid, reason) {
        print('userOffline  ${uid} ${reason}');
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      },
      leaveChannel: (stats) {
        print('leaveChannel ${stats.toJson()}');
        setState(() {
          isJoined = false;
          remoteUid.clear();
        });
      },
    ));
  }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    print("===========================>${widget.uid!}");

    await _engine.joinChannel(token, channelId, null, 0);
  }

  _leaveChannel() async {
    try{
      await _engine.leaveChannel();
    }catch(e){}

    widget.callback!("callCompleted");
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      print('switchCamera $err');
    });
  }

  _switchRender() {
    setState(() {
      switchRender = !switchRender;
      remoteUid = List.of(remoteUid.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(title: "Calling ${widget.CallerId}"),
      body: SafeArea(
          child: Container(
              decoration: AppWidget().chatImageDecoration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !isCallAudio! ? _renderVideo() : SizedBox(),
                  Container(
                    child: isCallAudio!
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Expanded(child: SizedBox()),
                                Expanded(
                                    child: GestureDetector(
                                  child: Icon(Icons.video_call),
                                  onTap: () {
                                    if (isCallAudio!)
                                      _engine.disableVideo().then((value) =>
                                          setState(() =>
                                              isCallAudio = !isCallAudio!));
                                    else {
                                      _engine.enableVideo().then((value) =>
                                          setState(() =>
                                              isCallAudio = !isCallAudio!));
                                    }
                                    // _initEngine();
                                  },
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: this._leaveChannel,
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.all(5),
                                    child: Icon(Icons.call_end),
                                  ),
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  child: Icon(isSpeaker
                                      ? Icons.volume_up
                                      : Icons.hearing_sharp),
                                  onTap: () {
                                    if (isSpeaker) {
                                      _engine.enableInEarMonitoring(false).then(
                                          (value) => setState(
                                              () => isSpeaker = !isSpeaker));
                                    } else {
                                      _engine.setEnableSpeakerphone(true).then(
                                          (value) => setState(
                                              () => isSpeaker = !isSpeaker));
                                    }
                                  },
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  child: Icon(
                                      isNotMuted ? Icons.mic : Icons.mic_off),
                                  onTap: () {
                                    if (isNotMuted) {
                                      _engine
                                          .muteAllRemoteAudioStreams(true)
                                          .then((value) => setState(
                                              () => isNotMuted = !isNotMuted));
                                    } else {
                                      _engine
                                          .muteAllRemoteAudioStreams(false)
                                          .then((value) => setState(
                                              () => isNotMuted = !isNotMuted));
                                    }
                                  },
                                )),
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                if (defaultTargetPlatform ==
                                        TargetPlatform.android ||
                                    defaultTargetPlatform == TargetPlatform.iOS)
                                  Expanded(
                                      child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: this._switchCamera,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1, color: Colors.white)),
                                      child: Icon(Icons.cameraswitch),
                                    ),
                                  )),
                                Expanded(
                                    child: GestureDetector(
                                  child: Icon(Icons.video_call),
                                  onTap: () {
                                    if (isCallAudio!)
                                      _engine.disableVideo().then((value) =>
                                          setState(() =>
                                              isCallAudio = !isCallAudio!));
                                    else {
                                      _engine.enableVideo().then((value) =>
                                          setState(() =>
                                              isCallAudio = !isCallAudio!));
                                    }
                                  },
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: this._leaveChannel,
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Icon(Icons.call_end),
                                  ),
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  child: Icon(isNotMuted
                                      ? Icons.volume_up
                                      : Icons.volume_off),
                                  onTap: () {
                                    if (isNotMuted) {
                                      _engine.disableAudio().then((value) =>
                                          setState(
                                              () => isNotMuted = !isNotMuted));
                                    } else {
                                      _engine.enableAudio().then((value) =>
                                          setState(
                                              () => isNotMuted = !isNotMuted));
                                    }
                                  },
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async =>
                                      await _engine.disableVideo(),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1, color: Colors.white)),
                                    child: Icon(Icons.perm_camera_mic_rounded),
                                  ),
                                )),
                              ]),
                    color: CustomColor.themeColor,
                  )
                ],
              ))),
    );
  }

  _renderVideo() {
    return Expanded(
      child: Stack(
        children: [
          Container(
            child: (kIsWeb || _isRenderSurfaceView)
                ? RtcLocalView.SurfaceView(
                    zOrderMediaOverlay: true,
                    zOrderOnTop: true,
                  )
                : RtcLocalView.TextureView(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.of(remoteUid.map(
                  (e) => GestureDetector(
                    onTap: this._switchRender,
                    child: Container(
                      width: 120,
                      height: 120,
                      child: (kIsWeb || _isRenderSurfaceView)
                          ? RtcRemoteView.SurfaceView(
                              uid: e,
                              channelId: channelId,
                            )
                          : RtcRemoteView.TextureView(
                              uid: e,
                              channelId: channelId,
                            ),
                    ),
                  ),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

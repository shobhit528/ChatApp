import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:logger/logger.dart' show Level, Logger;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/ColorConstant.dart';

// typedef _Fn = void Function();
class Recorder {
  FlutterSoundRecorder? recorder;

  bool recorderInitialised = false;

  bool get isRecording => recorder!.isRecording;

  String? tofile = Platform.isAndroid
      ? '/sdcard/Download/voicenote.wav'
      : 'storage/emulated/0/voicenote.wav';

  Future init() async {
    recorder = FlutterSoundRecorder(logLevel: Level.nothing);
    final status = await Permission.microphone.request();
    final storage = await Permission.storage.request();
    final externalStorage = await Permission.manageExternalStorage.request();
    if (status == PermissionStatus.granted) {
    } else if (externalStorage == PermissionStatus.permanentlyDenied) {}
    if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
    recorder!.openAudioSession(
        device: AudioDevice.speaker, mode: SessionMode.modeDefault);
    recorder!.setSubscriptionDuration(Duration(milliseconds: 10));
    recorderInitialised = true;
    return true;
  }

  dispose() async {
    recorder!.closeAudioSession();
    recorder = null;
    recorderInitialised = false;
  }

  Future startRecord({Function? callback}) async {
      if(Platform.isAndroid) {
        Directory dir = Directory(path.dirname(tofile!));
        if (!dir.existsSync()) dir.createSync();
      }else{
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      tofile=appDocPath+"/chatApp/voicenote.wav";
      Directory dir = Directory(path.dirname(tofile!));
      dynamic value= dir.existsSync();
      if(value !=true) {
        dir.createSync();
      }
    }

    if (recorderInitialised) {
      return await recorder!
          .startRecorder(toFile: tofile, codec: Codec.pcm16WAV);
    }
  }

  Future stopRecord() async {
    if (recorderInitialised) {
      // streamSubscription!.cancel();
      await recorder!.stopRecorder();
    }
  }

  Future toggleRecord() async {
    if (recorder!.isStopped) {
      await startRecord();
    } else {
      await stopRecord();
    }
  }
}

class Player {
  Rx<FlutterSoundPlayer>? player;
  var playerInitialised = false.obs;

  init() {
    player = FlutterSoundPlayer(logLevel: Level.nothing).obs;
    player!.value.openAudioSession();
    playerInitialised(true);
  }

  dispose() async {
    player!.value.closeAudioSession();
    player!(null);
    playerInitialised(false);
  }

  Future startPlaying({String? url, Function? callback}) async {
    if (playerInitialised.isTrue) {
      if (player!.value.isPlaying) await player!.value.stopPlayer();
      callback!(true);
      return await player!.value.startPlayer(
          fromURI: url,
          whenFinished: () {
            callback(false);
            stopPlaying();
          });
    }
  }

  Future stopPlaying() async {
    if (playerInitialised.isTrue) {
      return await player!.value.stopPlayer();
    }
  }

  Future pausePlaying() async {
    if (playerInitialised.isTrue) return await player!.value.pausePlayer();
  }

  Future resumePlaying() async {
    if (playerInitialised.isTrue) return await player!.value.resumePlayer();
  }

  Future togglePlaying(String url) async {
    if (playerInitialised.isTrue) {
      if (player!.value.isPlaying)
        return await player!.value.pausePlayer();
      else if (player!.value.isPaused)
        return await player!.value.resumePlayer();
      else if (player!.value.isStopped)
        return await player!.value
            .startPlayer(fromURI: url, whenFinished: () => stopPlaying());
      else
        return await player!.value.stopPlayer();
    }
  }

  buildWidget(url, duration) {
    var initValue = 0.0.obs, isPlaying = false.obs, isloading = false.obs;
    Timer? timer;
    final PlayingButton = Flexible(
      child: GestureDetector(
        onTap: () async {
          isloading(true);
          startPlaying(
              url: url,
              callback: (bool isplay) {
                isPlaying(isplay);
              }).whenComplete(() {
            isloading(false);
            timer = Timer.periodic(Duration(milliseconds: 1), (t) {
              initValue(double.parse((t.tick / 1000).toString()));
              if (t.tick > 3000 && isPlaying.isFalse) {
                initValue(0.0);
                t.cancel();
              }
              if (t.tick == duration * 1000) {
                stopPlaying();
                isPlaying(false);
                initValue(0.0);
                t.cancel();
              }
            });
          });
        },
        child: Icon(Icons.play_arrow),
      ),
    );
    final StopingButton = Flexible(
      child: GestureDetector(
        onTap: () async {
          timer!.cancel();
          stopPlaying();
          isPlaying(false);
          initValue(0.0);
        },
        child: Icon(Icons.stop),
      ),
    );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Obx(() => isPlaying.value
          ? StopingButton
          : isloading.isTrue
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : PlayingButton),
      Obx(() => Flexible(
              child: Slider(
            activeColor: CustomColor.themeColor,
            inactiveColor: Colors.grey,
            thumbColor: Colors.blueGrey,
            value: initValue.value,
            label: "${initValue.value}",
            max: double.parse(duration.toString()),
            min: 0,
            divisions: 4,
            onChanged: (val) {},
          )))
    ]);
  }
}

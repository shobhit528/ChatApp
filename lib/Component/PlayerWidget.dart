import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant/ColorConstant.dart';

class PlayerView extends StatefulWidget {
  final PlayerController playerController;
  final double length;

  const PlayerView(
      {Key? key, required this.length, required this.playerController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  Duration duration = Duration();
  Timer? timer;
  double initValue = 0.0;

  @override
  void initState() {
    super.initState();
    widget.playerController.addListener(() {
      if (widget.playerController.value) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  void startTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) reset();
    timer = Timer.periodic(Duration(microseconds: 10), (_) => addtime());
  }

  void stopTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) reset();
    setState(() => timer?.cancel());
  }

  void reset() => setState(() => duration = Duration());

  void addtime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      widget.playerController.value
          ? Flexible(
              child: GestureDetector(
                onTap: () async {
                  timer!.cancel();
                  // stopPlaying();
                  setState(() => initValue = 0.0);
                },
                child: Icon(Icons.stop),
              ),
            )
          : Flexible(
              child: GestureDetector(
                onTap: () {},
                child: Icon(Icons.play_arrow),
              ),
            ),
      Expanded(
          child: Slider(
        activeColor: CustomColor.themeColor,
        inactiveColor: Colors.grey,
        thumbColor: Colors.blue,
        value: initValue,
        label: "${initValue}",
        max: widget.length,
        min: 0.0,
        divisions: 4,
        onChanged: (val) {},
      ))
    ]);
  }
}

class PlayerController extends ValueNotifier<bool> {
  PlayerController({bool isPlaying = false}) : super(isPlaying);

  void startPlayer() => value = true;

  void stopPlayer() => value = false;
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  TextView(
      {@required this.label,
        this.textAlign,
        this.fontWeight,
        this.color,
        this.fontSize,
        this.fontStyle,
        this.onPress,
        this.type,
        this.underline,
        this.fontFamily});

  final String? label;
  final textAlign;
  final fontWeight;
  final color;
  final double? fontSize;
  final fontStyle;
  final onPress;
  final type;
  final underline;
  final fontFamily;

  @override
  Widget build(BuildContext context) {
    if (type == null)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: FlatButton(
          child: Text(
            label!,
            textScaleFactor: 1.0,
            textAlign: textAlign != null ? textAlign : TextAlign.center,
            style: TextStyle(
                fontWeight: fontWeight != null ? fontWeight : FontWeight.normal,
                color: color != null ? color : Colors.black,
                fontSize: fontSize ?? 15,
                fontStyle: fontStyle != null ? fontStyle : FontStyle.normal,
                fontFamily: fontFamily ?? "poppins_regular",
                decoration: underline == null
                    ? TextDecoration.none
                    : TextDecoration.underline),
          ),
          onPressed: onPress,
        ),
      );
    else
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onPress,
          child: Text(
            label!,
            textScaleFactor: 1.0,
            textAlign: textAlign != null ? textAlign : TextAlign.center,
            style: TextStyle(
                fontWeight: fontWeight != null ? fontWeight : FontWeight.normal,
                color: color != null ? color : Colors.black,
                fontSize: fontSize ?? 15,
                fontStyle: fontStyle != null ? fontStyle : FontStyle.normal,
                fontFamily: fontFamily ?? "poppins_regular",
                decoration: underline == null
                    ? TextDecoration.none
                    : TextDecoration.underline),
          ),
        ),
      );
  }
}

class TextViewNew extends StatelessWidget {
  TextViewNew(this.Name,
      {this.textAlign = TextAlign.start,
        this.fontWeight = FontWeight.normal,
        this.color,
        this.fontSize = 14,
        this.fontFamily});

  String Name;
  TextAlign textAlign;
  FontWeight fontWeight;
  final color;
  double fontSize;
  var fontFamily;

  @override
  Widget build(BuildContext context) {
    return Text(
      Name,
      textAlign: textAlign,
      style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamily: fontFamily),
    );
  }
}

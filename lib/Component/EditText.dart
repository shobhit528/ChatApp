import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../constant/ColorConstant.dart';
import '../constant/appConstant.dart';

class EditText extends StatelessWidget {
  EditText(
      {this.initialValue,
      this.fieldKey,
      this.maxLength,
      this.maxLine,
      this.hintText,
      this.validator,
      this.obscure_text,
      this.textEditingController,
      this.icon_val,
      this.textInputType,
      this.onSaved,
      this.onChanged,
      this.onFieldSubmitted,
      this.textInputAction,
      this.focusNode,
      this.autofocus,
      this.width,
      this.enabled,
      this.margin,
      this.contentPadding,
      this.bgColor,
      this.maxHeight,
      this.fontSize,
      this.textCapitalization,
      this.marginTop,
      this.onEditingComplete,
      this.TextColor,
      this.inputFormatters});

  final double? marginTop;
  final TextCapitalization? textCapitalization;
  final double? fontSize;
  final double? maxHeight;
  final String? initialValue;
  final Key? fieldKey;
  final bool? autofocus;
  final int? maxLength;
  final int? maxLine;
  final double? width;
  final String? hintText;
  final Color? bgColor;
  final FormFieldValidator<String>? validator;
  final bool? obscure_text;
  final IconData? icon_val;
  final TextEditingController? textEditingController;
  final TextInputType? textInputType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final focusNode;
  final enabled;
  final inputFormatters;
  final EdgeInsets? margin;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsets? contentPadding;
  final onEditingComplete;
  final TextColor;

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(Get.context!);
    final mqDataNew = mqData.copyWith(textScaleFactor: 1.0);
    return Container(
      width: width,
      constraints:
          BoxConstraints(maxHeight: maxHeight != null ? maxHeight! : 45,minHeight: 45),
      padding: EdgeInsets.only(
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
      ),
      margin: margin ??
          EdgeInsets.only(
              left: 5, right: 5, top: marginTop != null ? marginTop! : 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
          color: bgColor != null ? bgColor : Colors.white),
      child: Wrap(alignment: WrapAlignment.center, children: [
        MediaQuery(
            data: mqDataNew,
            child: TextFormField(
              // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[~+a-zA-Z0-9]+$'))],
              inputFormatters: inputFormatters ?? [],
              initialValue: initialValue,
              enabled: enabled ?? true,
              focusNode: focusNode,
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              textInputAction: textInputAction,
              key: fieldKey,
              autofocus: autofocus != null ? true : false,
              validator: validator,
              keyboardType: textInputType,
              autocorrect: false,
              controller: textEditingController,
              maxLength: maxLength ?? 100,
              maxLines: maxLine ?? 1,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: hintText,
                counter: SizedBox.shrink(),
                contentPadding:
                    contentPadding ?? EdgeInsets.fromLTRB(5, 0, 5, 5),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                icon: icon_val != null
                    ? Container(
                        height: 50,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                        child: Icon(
                          icon_val,
                          size: 18,
                        ),
                      )
                    : null,
              ),
              obscureText: obscure_text ?? false,
              onSaved: onSaved,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              style: TextStyle(
                  fontSize: fontSize, color: TextColor ?? Colors.black),
            )),
      ]),
    );
  }
}

class InputTextView extends StatelessWidget {
  TextEditingController textEditingController = new TextEditingController();

  InputTextView(
      {this.onChange,
        this.hintText,
        this.labelText,
        this.type,
        this.secureText,
        this.iconClick,
        this.maxLength,
        this.textAlign});

  Function? onChange;
  Function()? iconClick;
  String? labelText, hintText;
  String? type;
  TextAlign? textAlign;
  int? maxLength;
  bool? secureText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: CustomColor.themeColor)),
        child: TextFormField(
          textAlign: textAlign ?? TextAlign.left,
          maxLength: maxLength,
          obscureText: secureText == null ? false : secureText!,
          keyboardType: type == "number"
              ? TextInputType.number
              : TextInputType.emailAddress,
          // inputFormatters: [
          //   FilteringTextInputFormatter.digitsOnly
          // ],

          decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: hintText,
              suffixIcon: secureText == null
                  ? SizedBox()
                  : GestureDetector(
                  onTap: iconClick!,
                  behavior: HitTestBehavior.translucent,
                  child: Icon(secureText!
                      ? Icons.visibility_off
                      : Icons.visibility)),
              contentPadding: EdgeInsets.all(5),
              label: Text(labelText ?? Provider.of<AppConst>(context).name)),
          controller: textEditingController,
          onChanged: (value) => onChange!(value),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:darkchat/constants/network/cachhelper.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../cubit/cubitchat/cubit.dart';

var id = CacheHelper.getData(key: "id");
var lang = CacheHelper.getData(key: "lang");
var theme = CacheHelper.getData(key: "theme") == null
    ? false
    : CacheHelper.getData(key: "theme");
var defcolor = HexColor('F4A135');

isdark({
  required Color trueco,
  required Color falseco,
}) =>
    theme == false ? trueco : falseco;

navto({required BuildContext context, required Widget screen}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
}

navof({required BuildContext context, required Widget screen}) {
  Navigator.of(context).pushAndRemoveUntil(
      (MaterialPageRoute(builder: (context) => screen)), (route) => false);
}

deftext({
  required String text,
  required double size,
  Color? color,
  FontWeight fontWeight = FontWeight.bold,
  int? maxlines,
  TextOverflow? overflow,
  TextAlign? textalign,
}) =>
    Text(
      text,
      textAlign: textalign,
      overflow: overflow,
      maxLines: maxlines,
      style: GoogleFonts.changa(
          textStyle: TextStyle(
              fontSize: size,
              color: color == null
                  ? theme == true
                      ? Colors.white
                      : HexColor("404040")
                  : color),
          fontWeight: fontWeight),
    );

defbutton(
        {required String text,
        required Function() ontap,
        double widht = double.infinity,
        double height = 50}) =>
    Container(
      width: widht,
      height: height,
      decoration: BoxDecoration(
        color: HexColor('F15223'),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isdark(falseco: HexColor('1A1A1A'), trueco: Colors.grey),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(3, 4), // ion of shadow
          ),
        ],
      ),
      child: MaterialButton(
        disabledColor: Colors.amber,
        onPressed: ontap == null ? null : ontap,
        child: deftext(text: text, size: 20, color: Colors.white),
      ),
    );

defFormFiled({
  required String text,
  IconData? iconData,
  TextInputType? textInputType,
  TextInputAction? textInputAction,
  required String? Function(String?)? validator,
  required TextEditingController controller,
  int? maxlenght,
  Function()? ontap,
  String? maxtext,
  bool? enable,
  IconData? suffix,
  Function()? suffixontap,
  int? maxline,
  bool? obscureText,
}) =>
    TextFormField(
      maxLines: maxline == null ? null : maxline,
      validator: validator,
      readOnly: enable == false ? true : false,
      maxLength: maxlenght,
      textInputAction: textInputAction,
      cursorColor: defcolor,
      obscureText: obscureText == true ? true : false,
      decoration: InputDecoration(
        counterText: maxtext,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: HexColor('F4A135'),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: HexColor('F4A135'),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: HexColor('F4A135'),
          ),
        ),
        labelText: text,
        labelStyle: TextStyle(
            color: isdark(trueco: HexColor('1A1A1A'), falseco: Colors.white)),
        fillColor: theme == true ? Colors.grey.withOpacity(0.3) : null,
        filled: true,
        suffixIcon: IconButton(
          icon: Icon(suffix),
          onPressed: suffixontap,
          color: defcolor,
        ),
        prefixIcon: Icon(
          iconData,
          color: defcolor,
        ),
      ),
      keyboardType: textInputType,
      controller: controller,
      onTap: ontap,
    );

Widget emoji(controller, context, hide) => Offstage(
      offstage: hide,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
            textEditingController: controller,

            onBackspacePressed: () {
              controller
                ..text = controller.text.characters.skipLast(1).toString()
                ..selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length));
            },
            config: Config(
                columns: 7,
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                initCategory: Category.RECENT,
                bgColor: isdark(
                    trueco: HexColor('FAFAFA'), falseco: HexColor('404040')),
                indicatorColor: defcolor,
                iconColor: Colors.grey,
                iconColorSelected: defcolor,
                backspaceColor: Colors.red.withOpacity(0.5),
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                showRecentsTab: true,
                recentsLimit: 28,
                replaceEmojiOnLimitExceed: false,
                noRecents: const Text(
                  'No Recents',
                  style: TextStyle(fontSize: 20, color: Colors.black26),
                  textAlign: TextAlign.center,
                ),
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL)),
      ),
    );

Widget defCircular() => CircularProgressIndicator(
      color: defcolor,
    );

Widget defDiv() => Divider(
      color: isdark(trueco: Colors.black, falseco: Colors.white),
    );

Widget oflline(connected, context) => Positioned(
      height: 25.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        color: connected ? null : Color(0xFFEE4400),
        child: Center(
          child: deftext(
              text:
                  "${connected ? "" : AppLocalizations.of(context)!.disconnected}",
              size: 14),
        ),
      ),
    );

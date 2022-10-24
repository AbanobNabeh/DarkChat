import 'dart:io';

import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/network/cachhelper.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/view/screen/blockscreen.dart';
import 'package:darkchat/view/screen/editprofile.dart';
import 'package:darkchat/view/screen/mutescreen.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitHome, StatesHome>(
      builder: ((context, state) => Scaffold(
            appBar: AppBar(
              title: Text(trans.settings),
            ),
            body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(CubitHome.get(context)
                                      .modelProfile!
                                      .image!),
                                  fit: BoxFit.fill,
                                )),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                deftext(
                                    text: CubitHome.get(context)
                                        .modelProfile!
                                        .name!,
                                    size: 14,
                                    color: isdark(
                                        trueco: HexColor("404040"),
                                        falseco: HexColor("959595"))),
                                deftext(
                                    text: CubitHome.get(context)
                                        .modelProfile!
                                        .phonenumber!,
                                    size: 14,
                                    color: isdark(
                                        trueco: HexColor("404040"),
                                        falseco: HexColor("959595"))),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                navto(
                                    context: context,
                                    screen: EditProfileScreen());
                              },
                              icon: Icon(
                                NIcons.edit,
                                color: isdark(
                                    trueco: HexColor("404040"),
                                    falseco: HexColor("959595")),
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: deftext(text: trans.general, size: 16),
                    ),
                    tile(
                        text: trans.darktheme,
                        icon: Icons.dark_mode,
                        widget: CupertinoSwitch(
                            trackColor: HexColor("959595"),
                            activeColor: defcolor,
                            value: theme,
                            onChanged: (value) {
                              CubitHome.get(context)
                                  .changetheme(value, context);
                            }),
                        tap: () {
                          CubitHome.get(context).changetheme(!theme, context);
                        }),
                    tile(
                        text: trans.sarahah,
                        icon: Icons.mail_lock,
                        widget: CupertinoSwitch(
                            activeColor: defcolor,
                            trackColor: HexColor("959595"),
                            value:
                                CubitHome.get(context).modelProfile!.sarahah!,
                            onChanged: (value) {
                              CubitHome.get(context).onsarahah(value);
                            }),
                        tap: () {
                          CubitHome.get(context).onsarahah(
                              !CubitHome.get(context).modelProfile!.sarahah!);
                        },
                        subtitle: deftext(
                            text: trans.sarahahnote,
                            size: 10,
                            color: isdark(
                                trueco: HexColor("404040"),
                                falseco: HexColor("959595")))),
                    tile(
                        text: trans.private,
                        icon: Icons.lock,
                        widget: CupertinoSwitch(
                            trackColor: HexColor("959595"),
                            activeColor: defcolor,
                            value:
                                CubitHome.get(context).modelProfile!.private!,
                            onChanged: (value) {
                              CubitHome.get(context).onpriveta(value);
                            }),
                        tap: () {
                          CubitHome.get(context).onpriveta(
                              !CubitHome.get(context).modelProfile!.private!);
                        },
                        subtitle: deftext(
                            text: trans.privatenote,
                            size: 10,
                            color: isdark(
                                trueco: HexColor("404040"),
                                falseco: HexColor("959595")))),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: deftext(text: trans.preferences, size: 16),
                    ),
                    tile(
                        onLongPress: () {
                          if (lang == "ar_EG") {
                            CubitHome.get(context).changelang("en_US", context);
                          } else if (lang == "en_US") {
                            CubitHome.get(context).changelang("ar_EG", context);
                          } else {
                            if (Platform.localeName == "ar_EG") {
                              CubitHome.get(context)
                                  .changelang("en_US", context);
                            } else {
                              CubitHome.get(context)
                                  .changelang("ar_EG", context);
                            }
                          }
                        },
                        text: trans.language,
                        icon: Icons.language,
                        subtitle: deftext(
                            text: trans.changelang,
                            size: 14,
                            color: isdark(
                                trueco: HexColor("404040"),
                                falseco: HexColor("959595"))),
                        widget: Text(lang == null
                            ? Platform.localeName == "ar_EG"
                                ? trans.arabic
                                : trans.english
                            : lang == "ar_EG"
                                ? trans.arabic
                                : trans.english),
                        tap: () {}),
                    tile(
                        text: trans.mute,
                        icon: NIcons.volume_off,
                        widget: LeftButton(),
                        tap: () {
                          navto(context: context, screen: MuteScreen());
                        }),
                    tile(
                        text: trans.blocked,
                        icon: NIcons.block,
                        widget: LeftButton(),
                        tap: () {
                          navto(context: context, screen: BlockScreen());
                        }),
                    tile(
                        text: trans.logout,
                        icon: NIcons.logout,
                        widget: SizedBox(),
                        tap: () {
                          AlertDialog alert = AlertDialog(
                            title: deftext(text: trans.logout, size: 16),
                            content: deftext(text: trans.logoutnote, size: 16),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Sign Out'),
                                child: Text(trans.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  CubitHome.get(context).logout(context);
                                },
                                child: Text(trans.ok),
                              )
                            ],
                          );

                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        })
                  ]),
            ),
          )),
      listener: ((context, state) {}),
    );
  }
}

Widget tile({
  required String text,
  Widget? subtitle,
  required IconData icon,
  required Widget widget,
  required Function()? tap,
  Function()? onLongPress,
}) =>
    ListTile(
      onLongPress: onLongPress,
      subtitle: subtitle,
      title: Text(
        text,
        style: TextStyle(
          color:
              isdark(trueco: HexColor("404040"), falseco: HexColor("959595")),
        ),
      ),
      leading: Icon(
        icon,
        color: isdark(trueco: HexColor("404040"), falseco: HexColor("959595")),
      ),
      trailing: widget,
      onTap: tap,
    );
Icon LeftButton() {
  if (lang == null) {
    if (Platform.localeName == "en_US") {
      return Icon(
        NIcons.right_open,
        color: isdark(trueco: Colors.black, falseco: HexColor('959595')),
      );
    } else {
      return Icon(
        NIcons.left_open,
        color: isdark(trueco: Colors.black, falseco: HexColor('959595')),
      );
    }
  } else {
    if (lang == "en_US") {
      return Icon(
        NIcons.right_open,
        color: isdark(trueco: Colors.black, falseco: HexColor('959595')),
      );
    } else {
      return Icon(
        NIcons.left_open,
        color: isdark(trueco: Colors.black, falseco: HexColor('959595')),
      );
    }
  }
}

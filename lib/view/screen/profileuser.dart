import 'dart:io';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/view/screen/chat/chatscreen.dart';
import 'package:darkchat/view/screen/homepage.dart';
import 'package:darkchat/view/screen/saraha/saraha.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../cubit/cubitchat/states.dart';
import 'chat/sharemedia.dart';

class ProfileUserScreen extends StatelessWidget {
  String phonenumber;
  ProfileUserScreen(this.phonenumber);
  var scaffoldstate = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return Builder(builder: (context) {
      CubitHome.get(context).checklike(phonenumber: phonenumber);
      CubitHome.get(context).getuser(phonenumber: phonenumber);
      CubitHome.get(context).checkBlock(phonenumber);
      CubitHome.get(context).getProfile(phonenumber: id);
      CubitHome.get(context).checkmute(phonenumber);
      return BlocConsumer<CubitHome, StatesHome>(
          builder: (context, states) => Scaffold(
              key: scaffoldstate,
              appBar: AppBar(
                title: Text(trans.info),
              ),
              body: ConditionalBuilder(
                condition: states is GetUserLoading ||
                    states is CheckBlockLoading ||
                    states is CheckLikeLoading ||
                    states is GetProfileLoading,
                builder: (context) => Center(child: defCircular()),
                fallback: (context) => SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      InkWell(
                        onTap: () {
                          scaffoldstate.currentState!
                              .showBottomSheet((context) {
                            return PhotoViewGallery(
                              pageOptions: [
                                PhotoViewGalleryPageOptions(
                                  imageProvider: NetworkImage(
                                      CubitHome.get(context).userModel!.image!),
                                )
                              ],
                            );
                          });
                        },
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: HexColor('F4A135').withOpacity(0.3),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                CubitHome.get(context).userModel!.image!),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            CubitHome.get(context).userModel!.name!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          CircleAvatar(
                              radius: 7,
                              backgroundColor:
                                  CubitHome.get(context).userModel!.state ==
                                          'online'
                                      ? Colors.green
                                      : Colors.red)
                        ],
                      ),
                      Container(
                        width: 120,
                        child: deftext(
                          text: CubitHome.get(context).userModel!.bio!,
                          textalign: TextAlign.center,
                          size: 14,
                          fontWeight: FontWeight.normal,
                          maxlines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          states is CheckLikeLoading
                              ? defCircular()
                              : CubitHome.get(context).checkLike == true
                                  ? InkWell(
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        child: Icon(
                                          NIcons.heart,
                                          color: Colors.red,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: isdark(
                                              trueco: HexColor("FFFFFF"),
                                              falseco: HexColor("CCCCCC")),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isdark(
                                                  falseco: HexColor('1A1A1A'),
                                                  trueco: Color.fromARGB(
                                                      142, 158, 158, 158)),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                              offset:
                                                  Offset(2, 4), // ion of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        AlertDialog alert = AlertDialog(
                                          backgroundColor: isdark(
                                              trueco: Colors.white,
                                              falseco: HexColor("404040")),
                                          title: Lottie.network(
                                              'https://assets3.lottiefiles.com/packages/lf20_VQ5Mu9.json',
                                              animate: true,
                                              width: 120,
                                              height: 120),
                                          content: deftext(
                                              text: trans.love, size: 14),
                                          actions: [
                                            defbutton(
                                                text: trans.ok,
                                                ontap: () {
                                                  CubitHome.get(context)
                                                      .addfavoriteperson(
                                                          phonenumber:
                                                              phonenumber,
                                                          context: context);
                                                }),
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        child: Icon(NIcons.heart),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: isdark(
                                              trueco: HexColor("FFFFFF"),
                                              falseco: HexColor("CCCCCC")),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isdark(
                                                  falseco: HexColor('1A1A1A'),
                                                  trueco: Color.fromARGB(
                                                      142, 158, 158, 158)),
                                              spreadRadius: 2,
                                              blurRadius: 3,
                                              offset:
                                                  Offset(2, 4), // ion of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          SizedBox(
                            width: 25,
                          ),
                          InkWell(
                            onTap: () {
                              navto(
                                  context: context,
                                  screen: ChatScreen(
                                    phonenumber: phonenumber,
                                  ));
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(NIcons.comment),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isdark(
                                    trueco: HexColor("FFFFFF"),
                                    falseco: HexColor("CCCCCC")),
                                boxShadow: [
                                  BoxShadow(
                                    color: isdark(
                                        falseco: HexColor('1A1A1A'),
                                        trueco:
                                            Color.fromARGB(142, 158, 158, 158)),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: Offset(2, 4), // ion of shadow
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      item(() {
                        navto(
                            context: context,
                            screen: ShareMediaScreen(phonenumber));
                      }, NIcons.picture, trans.sharemedia, true),
                      item(() {
                        navto(
                            context: context,
                            screen: SarahaScreen(phonenumber));
                      }, Icons.contact_support, trans.sarahah, true),
                      item(() {
                        CubitHome.get(context).muteuser(phonenumber);
                      },
                          CubitHome.get(context).mute == true
                              ? NIcons.bell_alt
                              : NIcons.bell_off,
                          CubitHome.get(context).mute == true
                              ? trans.unmutenotifications
                              : trans.mute,
                          false),
                      item(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title:
                                deftext(text: trans.clearchatcontent, size: 18),
                            content:
                                deftext(text: trans.clearchatnote, size: 16),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Sign Out'),
                                child: Text(trans.cancel),
                              ),
                              TextButton(
                                onPressed: () => CubitHome.get(context)
                                    .clearchatcontent(phonenumber, context),
                                child: Text(trans.ok),
                              ),
                            ],
                          ),
                        );
                      }, NIcons.trash, trans.clearchatcontent, false),
                      item(() {
                        CubitHome.get(context).checkblock == false
                            ? scaffoldstate.currentState!
                                .showBottomSheet((context) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      deftext(
                                          text: trans.blocknote,
                                          size: 18,
                                          color: defcolor),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      defbutton(
                                          text: trans.ok,
                                          ontap: () {
                                            CubitHome.get(context).block(
                                                phonenumber: phonenumber);
                                            navof(
                                                context: context,
                                                screen: HomePage());
                                          }),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(trans.cancel))
                                    ],
                                  ),
                                );
                              })
                            : CubitHome.get(context)
                                .unblock(phonenumber: phonenumber);
                      },
                          Icons.block,
                          CubitHome.get(context).checkblock == true
                              ? trans.unblock
                              : trans.blocked,
                          false),
                      item(() {
                        AlertDialog alert = AlertDialog(
                          backgroundColor: isdark(
                              trueco: Colors.white,
                              falseco: HexColor("404040")),
                          title: Lottie.network(
                              'https://assets1.lottiefiles.com/private_files/lf30_kU41s4.json',
                              animate: true,
                              width: 120,
                              height: 120),
                          content: deftext(text: trans.reportcontact, size: 14),
                          actions: [
                            defbutton(
                                text: trans.ok,
                                ontap: () {
                                  CubitHome.get(context)
                                      .reportuser(phonenumber, context);
                                }),
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'cancel'),
                                child: Text(trans.cancel),
                              ),
                            ),
                          ],
                        );
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }, NIcons.thumbs_down_alt, trans.report, false),
                    ],
                  ),
                ),
              )),
          listener: (context, states) {});
    });
  }
}

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

Widget item(ontap, icon, text, leftbutton) => InkWell(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        height: 67,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color:
                    isdark(trueco: Colors.black, falseco: HexColor('959595')),
              ),
              SizedBox(
                width: 25,
              ),
              Expanded(
                child: deftext(text: text, size: 16),
              ),
              leftbutton == true
                  ? LeftButton()
                  : SizedBox(
                      width: 0,
                    )
            ],
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey.withOpacity(0.1)),
      ),
    );

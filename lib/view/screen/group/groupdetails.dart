import 'dart:io';

import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:darkchat/view/screen/group/editgroup.dart';
import 'package:darkchat/view/screen/group/members.dart';
import 'package:darkchat/view/screen/group/sharemedia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';

import '../../widget/message_icons.dart';

class GroupDetailsScreen extends StatelessWidget {
  String idgroup;
  GroupDetailsScreen(this.idgroup);
  GlobalKey<ScaffoldState> scaffoldstate = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
        create: (context) => CubitGroup()
          ..getGroupinfo(idgroup)
          ..checkmute(idgroup),
        child: Builder(builder: (context) {
          CubitGroup.get(context).checkmute(idgroup);
          return BlocConsumer<CubitGroup, StatesGroup>(
            builder: (context, state) => Scaffold(
                key: scaffoldstate,
                appBar: AppBar(
                  title: Text(trans.info),
                ),
                body: state is GetGroupLoading || state is CheckMuteGroup
                    ? Center(
                        child: defCircular(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                scaffoldstate.currentState!
                                    .showBottomSheet((context) {
                                  return PhotoViewGallery(
                                    pageOptions: [
                                      PhotoViewGalleryPageOptions(
                                        imageProvider: NetworkImage(
                                            CubitGroup.get(context)
                                                .group['image']),
                                      )
                                    ],
                                  );
                                });
                              },
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor:
                                    HexColor('F4A135').withOpacity(0.3),
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundImage: NetworkImage(
                                      CubitGroup.get(context).group['image']),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            deftext(
                                text: CubitGroup.get(context).group['name'],
                                size: 18),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ReadMoreText(
                                    "${CubitGroup.get(context).group['description']}",
                                    style: TextStyle(
                                      color: isdark(
                                          trueco: HexColor('404040'),
                                          falseco: HexColor('D1CDCD')),
                                    ),
                                    trimLines: 2,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText:
                                        AppLocalizations.of(context)!.readmore,
                                    trimExpandedText:
                                        AppLocalizations.of(context)!.showless,
                                    moreStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.withOpacity(0.1)),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            item(() {
                              navto(
                                  context: context,
                                  screen: ShareMediaScreen(idgroup));
                            }, NIcons.picture, trans.sharemedia, LeftButton(),
                                "top"),
                            item(() {
                              CubitGroup.get(context).muteGroup(idgroup);
                            },
                                CubitGroup.get(context).mute == false
                                    ? NIcons.bell_off
                                    : NIcons.bell_alt,
                                CubitGroup.get(context).mute == false
                                    ? trans.mute
                                    : trans.unmutenotifications,
                                LeftButton(),
                                ""),
                            item(() {
                              navto(
                                  context: context,
                                  screen: MembersScreen(idgroup));
                            }, NIcons.users, trans.members, LeftButton(), ""),
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
                                content: deftext(text: trans.repnote, size: 14),
                                actions: [
                                  defbutton(
                                      text: trans.ok,
                                      ontap: () {
                                        CubitGroup.get(context)
                                            .reportgroup(idgroup, context);
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
                            }, Icons.bug_report, trans.reportthegroup,
                                LeftButton(), "bottom"),
                            SizedBox(
                              height: 20,
                            ),
                            CubitGroup.get(context).me['state'] == "leader"
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      item(
                                          null,
                                          Icons.add,
                                          trans.canaddmembers,
                                          DropdownButton(
                                              hint: deftext(
                                                  text: CubitGroup.get(context)
                                                                  .group[
                                                              'canadd'] ==
                                                          "leader"
                                                      ? trans.leader
                                                      : trans.admin,
                                                  size: 12),
                                              items: [
                                                "${trans.admin}",
                                                "${trans.leader}"
                                              ]
                                                  .map((e) => DropdownMenuItem(
                                                        child: Text("$e"),
                                                        value: e,
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                if (value == trans.admin) {
                                                  CubitGroup.get(context)
                                                      .canadd(idgroup, "admin");
                                                } else {
                                                  CubitGroup.get(context)
                                                      .canadd(
                                                          idgroup, "leader");
                                                }
                                              }),
                                          "top"),
                                      item(
                                          null,
                                          NIcons.chat,
                                          trans.cansendamessage,
                                          DropdownButton(
                                              hint: deftext(
                                                  text: CubitGroup.get(context)
                                                                  .group[
                                                              'cansendmessage'] ==
                                                          "anyone"
                                                      ? trans.members
                                                      : trans.admin,
                                                  size: 12),
                                              items: [
                                                "${trans.admin}",
                                                "${trans.members}"
                                              ]
                                                  .map((e) => DropdownMenuItem(
                                                        child: Text("$e"),
                                                        value: e,
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                if (value == trans.admin) {
                                                  CubitGroup.get(context)
                                                      .cansendmessage(
                                                          idgroup, "admin");
                                                } else {
                                                  CubitGroup.get(context)
                                                      .cansendmessage(
                                                          idgroup, "anyone");
                                                }
                                              }),
                                          ""),
                                      item(() {
                                        navto(
                                            context: context,
                                            screen: EditGroupScreen(idgroup));
                                      }, NIcons.edit, trans.editgroup,
                                          LeftButton(), ""),
                                      item(() {
                                        AlertDialog alert = AlertDialog(
                                          title: Text(
                                            trans.removegroup,
                                            style: TextStyle(color: defcolor),
                                          ),
                                          content: Text(trans.deletegroup),
                                          actions: [
                                            TextButton(
                                              child: Text(trans.cancel),
                                              onPressed: () => Navigator.pop(
                                                  context, 'Sign Out'),
                                            ),
                                            TextButton(
                                              child: Text(trans.ok),
                                              onPressed: () {
                                                CubitGroup.get(context)
                                                    .removeGroup(
                                                        idgroup, context);
                                              },
                                            ),
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      }, NIcons.trash, trans.removegroup,
                                          SizedBox(), "bottom"),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 8, end: 8),
                                    child: InkWell(
                                      onTap: () {
                                        AlertDialog alert = AlertDialog(
                                          title: Text(
                                            trans.leavinggroup,
                                            style: TextStyle(color: defcolor),
                                          ),
                                          content: Text(trans.leavinggroupnote),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, 'Cancel');
                                                },
                                                child: Text(trans.cancel)),
                                            TextButton(
                                                onPressed: () {
                                                  CubitGroup.get(context)
                                                      .leavegroup(
                                                          idgroup, context);
                                                },
                                                child: Text(trans.ok)),
                                          ],
                                        );

                                        // show the dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 67,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.exit_to_app_outlined,
                                                color: isdark(
                                                    trueco: Colors.black,
                                                    falseco:
                                                        HexColor('959595')),
                                              ),
                                              SizedBox(
                                                width: 25,
                                              ),
                                              Expanded(
                                                child: deftext(
                                                    text: trans.leavinggroup,
                                                    size: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color:
                                                Colors.grey.withOpacity(0.1)),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Align(
                                child: Text(
                                    "${trans.createby} ${CubitGroup.get(context).group['createdby']} \n ${DateFormat.yMd().format(DateTime.parse(CubitGroup.get(context).group['datecreategroup']))}"),
                                alignment: AlignmentDirectional.bottomStart,
                              ),
                            ),
                          ],
                        ),
                      )),
            listener: (context, state) {},
          );
        }));
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

Widget item(ontap, icon, text, leftbutton, circular) => Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
      child: InkWell(
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
                leftbutton
              ],
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: circular == "top"
                  ? BorderRadius.vertical(top: Radius.circular(8))
                  : circular == "bottom"
                      ? BorderRadius.vertical(bottom: Radius.circular(8))
                      : BorderRadius.zero,
              color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );

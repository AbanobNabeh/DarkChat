import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/model/messagegroupmodel.dart';
import 'package:darkchat/model/messagemodel.dart';
import 'package:darkchat/view/screen/chat/PDFview.dart';
import 'package:darkchat/view/screen/group/groupdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../constants/constants.dart';
import '../../../cubit/cubitgroup/states.dart';
import '../../widget/message_icons.dart';
import '../chat/chatscreen.dart';

class GroupScreen extends StatelessWidget {
  TextEditingController message = TextEditingController();
  var formstate = GlobalKey<FormState>();
  var scaffoldstate = GlobalKey<ScaffoldState>();
  FocusNode focusNode = FocusNode();
  ItemScrollController scrollController = ItemScrollController();
  String idgroup;
  GroupScreen(this.idgroup);
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
        create: (context) => CubitGroup()
          ..getGroupinfo(idgroup)
          ..getmessages(idgroup),
        child: Builder(builder: (context) {
          CubitGroup.get(context).getmessages(idgroup);
          CubitGroup.get(context).getGroupinfo(idgroup);
          CubitGroup.get(context).initstate();
          return BlocConsumer<CubitGroup, StatesGroup>(
            builder: (context, state) {
              return Scaffold(
                key: scaffoldstate,
                appBar: state is GetGroupLoading
                    ? null
                    : AppBar(
                        centerTitle: false,
                        title: InkWell(
                          onTap: () {
                            navto(
                                context: context,
                                screen: GroupDetailsScreen(idgroup));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    HexColor('F4A135').withOpacity(0.3),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      CubitGroup.get(context).group['image']),
                                ),
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: deftext(
                                    text: CubitGroup.get(context).group['name'],
                                    size: 15,
                                    maxlines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )
                            ],
                          ),
                        ),
                      ),
                body: OfflineBuilder(
                  connectivityBuilder: (
                    BuildContext context,
                    ConnectivityResult connectivity,
                    Widget child,
                  ) {
                    final bool connected =
                        connectivity != ConnectivityResult.none;
                    return Stack(
                      fit: StackFit.expand,
                      children: [child, oflline(connected, context)],
                    );
                  },
                  child: Form(
                    key: formstate,
                    child: Column(
                      children: [
                        Expanded(
                            child: state is GetMessageLoading
                                ? Center(
                                    child: defCircular(),
                                  )
                                : ScrollablePositionedList.separated(
                                    reverse: true,
                                    itemScrollController: scrollController,
                                    itemBuilder: (context, index) {
                                      var cubit =
                                          CubitGroup.get(context).messages;
                                      if (index == cubit.length - 1) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: deftext(
                                                text:
                                                    "${cubit[index].time!.substring(0, 11)}",
                                                size: 14,
                                              ),
                                            ),
                                            cubit[index].idsender == id
                                                ? sendermessage(
                                                    context,
                                                    CubitGroup.get(context)
                                                        .messages[index],
                                                    scrollController,
                                                    scaffoldstate,
                                                    index)
                                                : receivedmessage(
                                                    context,
                                                    CubitGroup.get(context)
                                                        .messages[index],
                                                    scrollController,
                                                    scaffoldstate,
                                                    index)
                                          ],
                                        );
                                      } else {
                                        if (cubit[index]
                                                .time!
                                                .substring(0, 11) ==
                                            cubit[index + 1]
                                                .time!
                                                .substring(0, 11)) {
                                          if (cubit[index].idsender == id) {
                                            return sendermessage(
                                                context,
                                                CubitGroup.get(context)
                                                    .messages[index],
                                                scrollController,
                                                scaffoldstate,
                                                index);
                                          } else {
                                            return receivedmessage(
                                                context,
                                                CubitGroup.get(context)
                                                    .messages[index],
                                                scrollController,
                                                scaffoldstate,
                                                index);
                                          }
                                        } else {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                child: deftext(
                                                  text:
                                                      "${cubit[index].time!.substring(0, 11)}",
                                                  size: 14,
                                                ),
                                              ),
                                              cubit[index].idsender == id
                                                  ? sendermessage(
                                                      context,
                                                      CubitGroup.get(context)
                                                          .messages[index],
                                                      scrollController,
                                                      scaffoldstate,
                                                      index)
                                                  : receivedmessage(
                                                      context,
                                                      CubitGroup.get(context)
                                                          .messages[index],
                                                      scrollController,
                                                      scaffoldstate,
                                                      index)
                                            ],
                                          );
                                        }
                                      }
                                    },
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 3,
                                        ),
                                    itemCount: CubitGroup.get(context)
                                        .messages
                                        .length)),
                        CubitGroup.get(context).group['cansendmessage'] ==
                                "admin"
                            ? CubitGroup.get(context).me['state'] == "member"
                                ? Container(
                                    color: isdark(
                                        trueco: HexColor("FFFFFF"),
                                        falseco: HexColor("CCCCCC")),
                                    width: double.infinity,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: deftext(
                                            text: trans.offmessage, size: 14),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              defcolor.withOpacity(0.5),
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: isdark(
                                                trueco: HexColor("FFFFFF"),
                                                falseco: HexColor("CCCCCC")),
                                            child: IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (context) {
                                                      return BlocProvider(
                                                        create: (context) =>
                                                            CubitGroup(),
                                                        child: BlocConsumer<
                                                            CubitGroup,
                                                            StatesGroup>(
                                                          builder: (context,
                                                                  state) =>
                                                              Container(
                                                            width:
                                                                double.infinity,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Card(
                                                                  borderOnForeground:
                                                                      true,
                                                                  color: isdark(
                                                                      trueco: HexColor(
                                                                          'FFFFFF'),
                                                                      falseco:
                                                                          HexColor(
                                                                              '404040')),
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      buttonbottomsheet(
                                                                          icon: NIcons
                                                                              .camera,
                                                                          text: trans
                                                                              .camera,
                                                                          ontap:
                                                                              () {
                                                                            CubitGroup.get(context).requsetsendcamera(
                                                                                context: context,
                                                                                idgroup: idgroup);
                                                                          }),
                                                                      buttonbottomsheet(
                                                                          icon: NIcons
                                                                              .picture,
                                                                          text: trans
                                                                              .mobileLibrary,
                                                                          ontap:
                                                                              () {
                                                                            CubitGroup.get(context).requsetsendimage(
                                                                                context: context,
                                                                                idgroup: idgroup);
                                                                          }),
                                                                      buttonbottomsheet(
                                                                          icon: NIcons
                                                                              .doc_text,
                                                                          text: trans
                                                                              .document,
                                                                          ontap:
                                                                              () {
                                                                            CubitGroup.get(context).filepicker(
                                                                                context: context,
                                                                                idgroup: idgroup);
                                                                          }),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                    child: defbutton(
                                                                        text: trans.cancel,
                                                                        ontap: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        })),
                                                              ],
                                                            ),
                                                          ),
                                                          listener: (context,
                                                              state) {},
                                                        ),
                                                      );
                                                    });
                                              },
                                              icon: Icon(
                                                NIcons.plus,
                                                size: 15,
                                                color: defcolor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CubitGroup.get(context)
                                                      .isRecording ==
                                                  true
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: isdark(
                                                        falseco:
                                                            HexColor('474747'),
                                                        trueco:
                                                            HexColor('E3E3E3')),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              CubitGroup.get(
                                                                      context)
                                                                  .removerecord();
                                                            },
                                                            icon: Icon(
                                                                NIcons.trash,
                                                                color: Colors
                                                                    .red)),
                                                        CubitGroup.get(context)
                                                            .buildTimer(),
                                                        state is StopRecordingStateLoading
                                                            ? defCircular()
                                                            : IconButton(
                                                                onPressed: () {
                                                                  CubitGroup.get(context).stop(
                                                                      message:
                                                                          message
                                                                              .text,
                                                                      context:
                                                                          context,
                                                                      idgroup:
                                                                          idgroup);
                                                                },
                                                                icon: Icon(
                                                                  Icons.send,
                                                                  color:
                                                                      defcolor,
                                                                )),
                                                      ]),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: isdark(
                                                        falseco:
                                                            HexColor('474747'),
                                                        trueco:
                                                            HexColor('E3E3E3')),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CubitGroup.get(context)
                                                                  .replaymessage ==
                                                              null
                                                          ? SizedBox()
                                                          : Container(
                                                              height: 55,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: isdark(
                                                                    falseco:
                                                                        HexColor(
                                                                            '474747'),
                                                                    trueco: HexColor(
                                                                        'E3E3E3')),
                                                              ),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  CubitGroup.get(context)
                                                                              .replaymessage!['image'] !=
                                                                          null
                                                                      ? Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(3.0),
                                                                          child:
                                                                              Image(image: NetworkImage(CubitGroup.get(context).replaymessage!['image'])),
                                                                        )
                                                                      : SizedBox(),
                                                                  Text(
                                                                    "|",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            35),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              3),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          deftext(
                                                                              text: CubitGroup.get(context).replaymessage!['namesender'],
                                                                              size: 12),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          deftext(
                                                                              text: CubitGroup.get(context).replaymessage!['image'] != null
                                                                                  ? trans.pictures
                                                                                  : CubitGroup.get(context).replaymessage!['document'] != null
                                                                                      ? CubitGroup.get(context).replaymessage!['document']
                                                                                      : CubitGroup.get(context).replaymessage!['recorde'] != null
                                                                                          ? trans.audiorecording
                                                                                          : CubitGroup.get(context).replaymessage!['message'],
                                                                              size: 12),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        CubitGroup.get(context)
                                                                            .removereplay();
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        color:
                                                                            defcolor,
                                                                        size:
                                                                            20,
                                                                      ))
                                                                ],
                                                              ),
                                                            ),
                                                      TextFormField(
                                                        focusNode: focusNode,
                                                        onTap: () {
                                                          CubitGroup.get(context)
                                                                      .emojihide ==
                                                                  true
                                                              ? null
                                                              : CubitGroup.get(
                                                                      context)
                                                                  .emoji();
                                                        },
                                                        controller: message,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "";
                                                          }
                                                        },
                                                        onChanged: (value) {
                                                          CubitGroup.get(
                                                                  context)
                                                              .istype(value);
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          errorBorder:
                                                              InputBorder.none,
                                                          focusedErrorBorder:
                                                              InputBorder.none,
                                                          errorStyle: TextStyle(
                                                              fontSize: 0),
                                                          hintText: trans
                                                              .writemessage,
                                                          hintStyle: TextStyle(
                                                              color: isdark(
                                                                  trueco: HexColor(
                                                                      'B4B3B3'),
                                                                  falseco: HexColor(
                                                                      '959595'))),
                                                          border:
                                                              InputBorder.none,
                                                          prefixIcon:
                                                              IconButton(
                                                            onPressed: () {
                                                              focusNode
                                                                  .unfocus();
                                                              focusNode
                                                                      .canRequestFocus =
                                                                  false;
                                                              CubitGroup.get(
                                                                      context)
                                                                  .emoji();
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .emoji_emotions_outlined,
                                                              color: isdark(
                                                                  trueco: HexColor(
                                                                      'B4B3B3'),
                                                                  falseco: HexColor(
                                                                      '959595')),
                                                            ),
                                                          ),
                                                          suffixIcon: CubitGroup
                                                                          .get(
                                                                              context)
                                                                      .isType ==
                                                                  true
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                    Icons.send,
                                                                    color:
                                                                        defcolor,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    if (formstate
                                                                        .currentState!
                                                                        .validate()) {
                                                                      CubitGroup.get(context).sendmessage(
                                                                          message: message
                                                                              .text,
                                                                          context:
                                                                              context,
                                                                          idgroup:
                                                                              idgroup);
                                                                      message.text =
                                                                          "";
                                                                    }
                                                                  },
                                                                )
                                                              : IconButton(
                                                                  icon: Icon(
                                                                    Icons.mic,
                                                                    color:
                                                                        defcolor,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    CubitGroup.get(
                                                                            context)
                                                                        .start();
                                                                  },
                                                                ),
                                                        ),
                                                        cursorColor: defcolor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          defcolor.withOpacity(0.5),
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isdark(
                                            trueco: HexColor("FFFFFF"),
                                            falseco: HexColor("CCCCCC")),
                                        child: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return BlocProvider(
                                                    create: (context) =>
                                                        CubitGroup(),
                                                    child: BlocConsumer<
                                                        CubitGroup,
                                                        StatesGroup>(
                                                      builder:
                                                          (context, state) =>
                                                              Container(
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Card(
                                                              borderOnForeground:
                                                                  true,
                                                              color: isdark(
                                                                  trueco: HexColor(
                                                                      'FFFFFF'),
                                                                  falseco: HexColor(
                                                                      '404040')),
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  buttonbottomsheet(
                                                                      icon: NIcons
                                                                          .camera,
                                                                      text: trans
                                                                          .camera,
                                                                      ontap:
                                                                          () {
                                                                        CubitGroup.get(context).requsetsendcamera(
                                                                            context:
                                                                                context,
                                                                            idgroup:
                                                                                idgroup);
                                                                      }),
                                                                  buttonbottomsheet(
                                                                      icon: NIcons
                                                                          .picture,
                                                                      text: trans
                                                                          .mobileLibrary,
                                                                      ontap:
                                                                          () {
                                                                        CubitGroup.get(context).requsetsendimage(
                                                                            context:
                                                                                context,
                                                                            idgroup:
                                                                                idgroup);
                                                                      }),
                                                                  buttonbottomsheet(
                                                                      icon: NIcons
                                                                          .doc_text,
                                                                      text: trans
                                                                          .document,
                                                                      ontap:
                                                                          () {
                                                                        CubitGroup.get(context).filepicker(
                                                                            context:
                                                                                context,
                                                                            idgroup:
                                                                                idgroup);
                                                                      }),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 10,
                                                                ),
                                                                child:
                                                                    defbutton(
                                                                        text: trans
                                                                            .cancel,
                                                                        ontap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        })),
                                                          ],
                                                        ),
                                                      ),
                                                      listener:
                                                          (context, state) {},
                                                    ),
                                                  );
                                                });
                                          },
                                          icon: Icon(
                                            NIcons.plus,
                                            size: 15,
                                            color: defcolor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CubitGroup.get(context)
                                                  .isRecording ==
                                              true
                                          ? Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: isdark(
                                                    falseco: HexColor('474747'),
                                                    trueco: HexColor('E3E3E3')),
                                              ),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          CubitGroup.get(
                                                                  context)
                                                              .removerecord();
                                                        },
                                                        icon: Icon(NIcons.trash,
                                                            color: Colors.red)),
                                                    CubitGroup.get(context)
                                                        .buildTimer(),
                                                    state is StopRecordingStateLoading
                                                        ? defCircular()
                                                        : IconButton(
                                                            onPressed: () {
                                                              CubitGroup.get(
                                                                      context)
                                                                  .stop(
                                                                      message:
                                                                          message
                                                                              .text,
                                                                      context:
                                                                          context,
                                                                      idgroup:
                                                                          idgroup);
                                                            },
                                                            icon: Icon(
                                                              Icons.send,
                                                              color: defcolor,
                                                            )),
                                                  ]),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: isdark(
                                                    falseco: HexColor('474747'),
                                                    trueco: HexColor('E3E3E3')),
                                              ),
                                              child: Column(
                                                children: [
                                                  CubitGroup.get(context)
                                                              .replaymessage ==
                                                          null
                                                      ? SizedBox()
                                                      : Container(
                                                          height: 55,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: isdark(
                                                                falseco: HexColor(
                                                                    '474747'),
                                                                trueco: HexColor(
                                                                    'E3E3E3')),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 15,
                                                              ),
                                                              CubitGroup.get(context)
                                                                              .replaymessage![
                                                                          'image'] !=
                                                                      null
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              3.0),
                                                                      child: Image(
                                                                          image:
                                                                              NetworkImage(CubitGroup.get(context).replaymessage!['image'])),
                                                                    )
                                                                  : SizedBox(),
                                                              Text(
                                                                "|",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        35),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          3),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      deftext(
                                                                          text: CubitGroup.get(context).replaymessage![
                                                                              'namesender'],
                                                                          size:
                                                                              12),
                                                                      SizedBox(
                                                                        height:
                                                                            3,
                                                                      ),
                                                                      deftext(
                                                                          text: CubitGroup.get(context).replaymessage!['image'] != null
                                                                              ? trans.pictures
                                                                              : CubitGroup.get(context).replaymessage!['document'] != null
                                                                                  ? CubitGroup.get(context).replaymessage!['document']
                                                                                  : CubitGroup.get(context).replaymessage!['recorde'] != null
                                                                                      ? trans.audiorecording
                                                                                      : CubitGroup.get(context).replaymessage!['message'],
                                                                          size: 12),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    CubitGroup.get(
                                                                            context)
                                                                        .removereplay();
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color:
                                                                        defcolor,
                                                                    size: 20,
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                  TextFormField(
                                                    focusNode: focusNode,
                                                    onTap: () {
                                                      CubitGroup.get(context)
                                                                  .emojihide ==
                                                              true
                                                          ? null
                                                          : CubitGroup.get(
                                                                  context)
                                                              .emoji();
                                                    },
                                                    controller: message,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return "";
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      CubitGroup.get(context)
                                                          .istype(value);
                                                    },
                                                    decoration: InputDecoration(
                                                      errorBorder:
                                                          InputBorder.none,
                                                      focusedErrorBorder:
                                                          InputBorder.none,
                                                      errorStyle: TextStyle(
                                                          fontSize: 0),
                                                      hintText:
                                                          trans.writemessage,
                                                      hintStyle: TextStyle(
                                                          color: isdark(
                                                              trueco: HexColor(
                                                                  'B4B3B3'),
                                                              falseco: HexColor(
                                                                  '959595'))),
                                                      border: InputBorder.none,
                                                      prefixIcon: IconButton(
                                                        onPressed: () {
                                                          focusNode.unfocus();
                                                          focusNode
                                                                  .canRequestFocus =
                                                              false;
                                                          CubitGroup.get(
                                                                  context)
                                                              .emoji();
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .emoji_emotions_outlined,
                                                          color: isdark(
                                                              trueco: HexColor(
                                                                  'B4B3B3'),
                                                              falseco: HexColor(
                                                                  '959595')),
                                                        ),
                                                      ),
                                                      suffixIcon: CubitGroup.get(
                                                                      context)
                                                                  .isType ==
                                                              true
                                                          ? IconButton(
                                                              icon: Icon(
                                                                Icons.send,
                                                                color: defcolor,
                                                              ),
                                                              onPressed: () {
                                                                if (formstate
                                                                    .currentState!
                                                                    .validate()) {
                                                                  CubitGroup.get(context).sendmessage(
                                                                      message:
                                                                          message
                                                                              .text,
                                                                      context:
                                                                          context,
                                                                      idgroup:
                                                                          idgroup);
                                                                  message.text =
                                                                      "";
                                                                }
                                                              },
                                                            )
                                                          : IconButton(
                                                              icon: Icon(
                                                                Icons.mic,
                                                                color: defcolor,
                                                              ),
                                                              onPressed: () {
                                                                CubitGroup.get(
                                                                        context)
                                                                    .start();
                                                              },
                                                            ),
                                                    ),
                                                    cursorColor: defcolor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                        emoji(message, context,
                            CubitGroup.get(context).emojihide),
                      ],
                    ),
                  ),
                ),
              );
            },
            listener: (context, state) {
              if (state is GetMessageSuccess) {
                CubitGroup.get(context).seenmessage(idgroup);
              }
            },
          );
        }));
  }
}

Widget receivedmessage(
        BuildContext context,
        MessageGroupModel groupModel,
        ItemScrollController scrollController,
        GlobalKey<ScaffoldState> scaffoldstate,
        int index) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onLongPress: () {
          if (groupModel.message == "" && groupModel.messageimage != null) {
            CubitGroup.get(context)
                .savephoto("${groupModel.messageimage}", context, false);
          } else if (groupModel.message != "" &&
              groupModel.messageimage == null) {
            Clipboard.setData(ClipboardData(text: groupModel.message))
                .then((value) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.messagecopied);
            });
          } else if (groupModel.message != "" &&
              groupModel.messageimage != null) {
            scaffoldstate.currentState!.showBottomSheet((context) => Container(
                  color: isdark(
                      trueco: HexColor("FAFAFA"), falseco: HexColor("404040")),
                  width: double.infinity,
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: bottomshetmessage(() {
                          Clipboard.setData(
                                  ClipboardData(text: groupModel.message))
                              .then((value) {
                            Fluttertoast.showToast(
                                msg: AppLocalizations.of(context)!
                                    .messagecopied);
                            Navigator.pop(context);
                          });
                        },
                            Icon(
                              NIcons.doc_text,
                              color: Colors.blue,
                            ),
                            AppLocalizations.of(context)!.copy),
                      ),
                      Expanded(
                        child: bottomshetmessage(() {
                          CubitGroup.get(context).savephoto(
                              "${groupModel.messageimage}", context, true);
                        }, Icon(NIcons.download, color: defcolor),
                            AppLocalizations.of(context)!.savePhoto),
                      )
                    ],
                  ),
                ));
          }
        },
        child: SwipeTo(
          onLeftSwipe: () {
            CubitGroup.get(context).replay({
              "message": groupModel.message,
              "namesender": groupModel.namesender,
              "id": groupModel.id,
              "image": groupModel.messageimage,
              "recorde": groupModel.messagerecord,
              "document": groupModel.document != null
                  ? groupModel.document!['name']
                  : null
            });
          },
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: groupModel.document != null
                      ? InkWell(
                          onTap: () {
                            DocumentModel model = DocumentModel(
                              bytes: groupModel.document!['bytes'],
                              name: groupModel.document!['name'],
                              link: groupModel.document!['link'],
                            );
                            navto(
                                context: context, screen: PDFviewScreen(model));
                          },
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: defcolor,
                              borderRadius: BorderRadiusDirectional.only(
                                  topEnd: Radius.circular(10),
                                  topStart: Radius.circular(10),
                                  bottomEnd: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: isdark(
                                      falseco: HexColor('1A1A1A'),
                                      trueco: Colors.grey),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(1, 4), // ion of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: deftext(
                                          text: groupModel.document!['name']!,
                                          size: 14,
                                          overflow: TextOverflow.ellipsis,
                                          maxlines: 1,
                                          color: Colors.white),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      deftext(
                                          text:
                                              "${DateFormat.jm().format(DateTime.parse(groupModel.time!))}",
                                          size: 12,
                                          color: Colors.white),
                                      deftext(
                                          text: CubitGroup.get(context)
                                              .formatSizefile(
                                                  groupModel
                                                      .document!['bytes']!,
                                                  context),
                                          size: 12,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            groupModel.messageimage != null
                                ? InkWell(
                                    onTap: () {
                                      scaffoldstate.currentState!
                                          .showBottomSheet(
                                        (context) => PhotoViewGallery(
                                          scrollPhysics:
                                              const BouncingScrollPhysics(),
                                          pageOptions: [
                                            PhotoViewGalleryPageOptions(
                                              imageProvider: NetworkImage(
                                                  groupModel.messageimage
                                                      .toString()),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minWidth: 80,
                                        maxWidth: 200,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(
                                                minWidth: 80,
                                                maxHeight: 200,
                                                maxWidth: 200,
                                                minHeight: 80),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    groupModel.messageimage!,
                                                  ),
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          groupModel.message != ""
                                              ? Container(
                                                  constraints: BoxConstraints(
                                                      minWidth: 15,
                                                      maxWidth: 200),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: ReadMoreText(
                                                      groupModel.message!,
                                                      style: TextStyle(
                                                        color: isdark(
                                                            trueco: HexColor(
                                                                '404040'),
                                                            falseco: HexColor(
                                                                'D1CDCD')),
                                                      ),
                                                      trimLines: 4,
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .readmore,
                                                      trimExpandedText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .showless,
                                                      moreStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue),
                                                    ),
                                                  ))
                                              : SizedBox(),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: isdark(
                                                  falseco: HexColor('1A1A1A'),
                                                  trueco: Colors.grey),

                                              spreadRadius: 2,

                                              blurRadius: 3,

                                              offset:
                                                  Offset(1, 4), // ion of shadow
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadiusDirectional.circular(
                                                  8),
                                          color: defcolor),
                                    ),
                                  )
                                : groupModel.messagerecord != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 290,
                                            height: 50,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        CubitGroup.get(context)
                                                            .isplaying(groupModel
                                                                .messagerecord);
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      icon: CubitGroup.get(
                                                                      context)
                                                                  .playlist[
                                                              groupModel
                                                                  .messagerecord]
                                                          ? Icon(
                                                              NIcons.pause,
                                                              size: 15,
                                                              color: defcolor,
                                                            )
                                                          : Icon(
                                                              NIcons.play,
                                                              size: 15,
                                                              color: defcolor,
                                                            ),
                                                    ),
                                                  ),
                                                  Slider(
                                                      max: CubitGroup.get(
                                                                      context)
                                                                  .playlist[
                                                              groupModel
                                                                  .messagerecord]
                                                          ? CubitGroup.get(
                                                                  context)
                                                              .duration
                                                              .inSeconds
                                                              .toDouble()
                                                          : 0,
                                                      value: CubitGroup.get(
                                                                      context)
                                                                  .playlist[
                                                              groupModel
                                                                  .messagerecord]
                                                          ? CubitGroup.get(
                                                                  context)
                                                              .position
                                                              .inSeconds
                                                              .toDouble()
                                                          : 0,
                                                      onChanged: (value) {
                                                        CubitGroup.get(context)
                                                                        .playlist[
                                                                    groupModel
                                                                        .messagerecord] ==
                                                                true
                                                            ? CubitGroup.get(
                                                                    context)
                                                                .slideronchange(
                                                                    value)
                                                            : null;
                                                      },
                                                      activeColor:
                                                          Colors.white),
                                                  deftext(
                                                      text: CubitGroup.get(
                                                                      context)
                                                                  .playlist[
                                                              groupModel
                                                                  .messagerecord]
                                                          ? CubitGroup.get(
                                                                  context)
                                                              .formatTime(
                                                                  CubitGroup.get(
                                                                          context)
                                                                      .position)
                                                          : "00:00",
                                                      size: 12,
                                                      color: Colors.white),
                                                ],
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                                color: defcolor,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        constraints: BoxConstraints(
                                            maxWidth: 250, minWidth: 50),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              groupModel.replay != null
                                                  ? InkWell(
                                                      onTap: () {
                                                        var indexed = CubitGroup
                                                                .get(context)
                                                            .messages
                                                            .indexWhere((item) =>
                                                                item.id ==
                                                                groupModel
                                                                        .replay![
                                                                    'id']);
                                                        indexed == -1
                                                            ? Fluttertoast.showToast(
                                                                msg: AppLocalizations.of(
                                                                        context)!
                                                                    .messagedeleted)
                                                            : scrollController
                                                                .scrollTo(
                                                                    index:
                                                                        indexed,
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1));
                                                      },
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: 250,
                                                                minWidth: 100),
                                                        height: 55,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              deftext(
                                                                  text: AppLocalizations.of(
                                                                          context)!
                                                                      .answered,
                                                                  size: 10,
                                                                  color: Colors
                                                                      .white),
                                                              deftext(
                                                                  text: groupModel.replay![
                                                                              'image'] !=
                                                                          null
                                                                      ? AppLocalizations.of(
                                                                              context)!
                                                                          .picture
                                                                      : groupModel.replay!['recorde'] !=
                                                                              null
                                                                          ? AppLocalizations.of(context)!
                                                                              .audiorecording
                                                                          : groupModel.replay!['document'] !=
                                                                                  null
                                                                              ? groupModel.replay![
                                                                                  'document']
                                                                              : groupModel.replay![
                                                                                  'message'],
                                                                  size: 16,
                                                                  maxlines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  color: Colors
                                                                      .white)
                                                            ],
                                                          ),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadiusDirectional
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              ReadMoreText(
                                                groupModel.message!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                trimLines: 4,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText:
                                                    AppLocalizations.of(
                                                            context)!
                                                        .readmore,
                                                trimExpandedText:
                                                    AppLocalizations.of(
                                                            context)!
                                                        .showless,
                                                moreStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: isdark(
                                                    falseco: HexColor('1A1A1A'),
                                                    trueco: Colors.grey),
                                                spreadRadius: 2,
                                                blurRadius: 3,
                                                offset: Offset(
                                                    1, 4), // ion of shadow
                                              ),
                                            ],
                                            color: defcolor,
                                            borderRadius:
                                                BorderRadiusDirectional.only(
                                                    bottomStart:
                                                        Radius.circular(10),
                                                    topStart:
                                                        Radius.circular(10),
                                                    bottomEnd:
                                                        Radius.circular(10))),
                                      ),
                            deftext(
                              text:
                                  "${DateFormat.jm().format(DateTime.parse(groupModel.time!))}",
                              size: 12,
                            )
                          ],
                        ),
                ),
                SizedBox(
                  width: 7,
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(groupModel.imagesender!),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Widget sendermessage(
        BuildContext context,
        MessageGroupModel groupModel,
        ItemScrollController scrollController,
        GlobalKey<ScaffoldState> scaffoldstate,
        int index) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onLongPress: () {
          scaffoldstate.currentState!.showBottomSheet((context) => Container(
                color: isdark(
                    trueco: HexColor("FAFAFA"), falseco: HexColor("404040")),
                width: double.infinity,
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: bottomshetmessage(() {
                        AlertDialog alert = AlertDialog(
                          title: deftext(
                              text:
                                  "${AppLocalizations.of(context)!.deletemessage}",
                              size: 16),
                          actions: [
                            TextButton(
                              onPressed: () {
                                CubitGroup.get(context).deletemessage(
                                    idgroup:
                                        CubitGroup.get(context).group['id'],
                                    idmessage: groupModel.id!,
                                    context: context);
                              },
                              child: deftext(
                                  text:
                                      "${AppLocalizations.of(context)!.delete}",
                                  size: 12),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: deftext(
                                  text:
                                      "${AppLocalizations.of(context)!.cancel}",
                                  size: 12),
                            ),
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
                          Icon(
                            NIcons.trash,
                            color: Colors.red,
                          ),
                          AppLocalizations.of(context)!.delete),
                    ),
                    groupModel.message != ""
                        ? Expanded(
                            child: bottomshetmessage(() {
                              Clipboard.setData(
                                      ClipboardData(text: groupModel.message))
                                  .then((value) {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!
                                        .messagecopied);
                                Navigator.pop(context);
                              });
                            },
                                Icon(
                                  NIcons.doc_text,
                                  color: Colors.blue,
                                ),
                                AppLocalizations.of(context)!.copy),
                          )
                        : SizedBox(),
                    groupModel.messageimage != null
                        ? Expanded(
                            child: bottomshetmessage(() {
                              CubitGroup.get(context).savephoto(
                                  "${groupModel.messageimage}", context, true);
                            }, Icon(NIcons.download, color: defcolor),
                                AppLocalizations.of(context)!.savePhoto),
                          )
                        : SizedBox(),
                  ],
                ),
              ));
        },
        child: SwipeTo(
          onRightSwipe: () {
            CubitGroup.get(context).replay({
              "message": groupModel.message,
              "namesender": groupModel.namesender,
              "id": groupModel.id,
              "image": groupModel.messageimage,
              "recorde": groupModel.messagerecord,
              "document": groupModel.document != null
                  ? groupModel.document!['name']
                  : null
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              groupModel.document != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {
                          DocumentModel model = DocumentModel(
                            bytes: groupModel.document!['bytes'],
                            name: groupModel.document!['name'],
                            link: groupModel.document!['link'],
                          );
                          navto(context: context, screen: PDFviewScreen(model));
                        },
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: isdark(
                                trueco: HexColor('F0F0F0'),
                                falseco: HexColor('373636')),
                            borderRadius: BorderRadiusDirectional.only(
                                topEnd: Radius.circular(10),
                                topStart: Radius.circular(10),
                                bottomEnd: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: isdark(
                                    falseco: HexColor('1A1A1A'),
                                    trueco: Colors.grey),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: Offset(1, 4), // ion of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: deftext(
                                        text: groupModel.document!['name']!,
                                        size: 14,
                                        overflow: TextOverflow.ellipsis,
                                        maxlines: 1),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isdark(
                                        trueco: Colors.grey.withOpacity(0.5),
                                        falseco:
                                            Colors.black54.withOpacity(0.5)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    deftext(
                                        text:
                                            "${DateFormat.jm().format(DateTime.parse(groupModel.time!))}",
                                        size: 12),
                                    deftext(
                                        text: CubitGroup.get(context)
                                            .formatSizefile(
                                                groupModel.document!['bytes']!,
                                                context),
                                        size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        groupModel.messageimage != null
                            ? InkWell(
                                onTap: () {
                                  scaffoldstate.currentState!.showBottomSheet(
                                    (context) => PhotoViewGallery(
                                      scrollPhysics:
                                          const BouncingScrollPhysics(),
                                      pageOptions: [
                                        PhotoViewGalleryPageOptions(
                                          imageProvider: NetworkImage(groupModel
                                              .messageimage
                                              .toString()),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 80,
                                    maxWidth: 200,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            minWidth: 80,
                                            maxHeight: 200,
                                            maxWidth: 200,
                                            minHeight: 80),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                groupModel.messageimage!,
                                              ),
                                              fit: BoxFit.fill,
                                            )),
                                      ),
                                      groupModel.message != ""
                                          ? Container(
                                              constraints: BoxConstraints(
                                                  minWidth: 15, maxWidth: 200),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: ReadMoreText(
                                                  groupModel.message!,
                                                  style: TextStyle(
                                                    color: isdark(
                                                        trueco:
                                                            HexColor('404040'),
                                                        falseco:
                                                            HexColor('D1CDCD')),
                                                  ),
                                                  trimLines: 4,
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .readmore,
                                                  trimExpandedText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .showless,
                                                  moreStyle: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue),
                                                ),
                                              ))
                                          : SizedBox(),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: isdark(
                                              falseco: HexColor('1A1A1A'),
                                              trueco: Colors.grey),

                                          spreadRadius: 2,

                                          blurRadius: 3,

                                          offset: Offset(1, 4), // ion of shadow
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadiusDirectional.circular(8),
                                      color: isdark(
                                          trueco: HexColor('F0F0F0'),
                                          falseco: HexColor('373636'))),
                                ),
                              )
                            : groupModel.messagerecord != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 290,
                                        height: 50,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 5,
                                              ),
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: isdark(
                                                    trueco: HexColor("FFFFFF"),
                                                    falseco:
                                                        HexColor("CCCCCC")),
                                                child: IconButton(
                                                  onPressed: () {
                                                    CubitGroup.get(context)
                                                        .isplaying(groupModel
                                                            .messagerecord);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  icon: CubitGroup.get(context)
                                                              .playlist[
                                                          groupModel
                                                              .messagerecord]
                                                      ? Icon(
                                                          NIcons.pause,
                                                          size: 15,
                                                          color: defcolor,
                                                        )
                                                      : Icon(
                                                          NIcons.play,
                                                          size: 15,
                                                          color: defcolor,
                                                        ),
                                                ),
                                              ),
                                              Slider(
                                                  max: CubitGroup.get(context)
                                                              .playlist[
                                                          groupModel
                                                              .messagerecord]
                                                      ? CubitGroup.get(context)
                                                          .duration
                                                          .inSeconds
                                                          .toDouble()
                                                      : 0,
                                                  value: CubitGroup.get(context)
                                                              .playlist[
                                                          groupModel
                                                              .messagerecord]
                                                      ? CubitGroup.get(context)
                                                          .position
                                                          .inSeconds
                                                          .toDouble()
                                                      : 0,
                                                  onChanged: (value) {
                                                    CubitGroup.get(context)
                                                                    .playlist[
                                                                groupModel
                                                                    .messagerecord] ==
                                                            true
                                                        ? CubitGroup.get(
                                                                context)
                                                            .slideronchange(
                                                                value)
                                                        : null;
                                                  },
                                                  activeColor: defcolor),
                                              deftext(
                                                  text: CubitGroup.get(context)
                                                              .playlist[
                                                          groupModel
                                                              .messagerecord]
                                                      ? CubitGroup.get(context)
                                                          .formatTime(
                                                              CubitGroup.get(
                                                                      context)
                                                                  .position)
                                                      : "00:00",
                                                  size: 12)
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: isdark(
                                                trueco: HexColor('F0F0F0'),
                                                falseco: HexColor('474747')),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                    ],
                                  )
                                : Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          groupModel.replay != null
                                              ? InkWell(
                                                  onTap: () {
                                                    var indexed = CubitGroup
                                                            .get(context)
                                                        .messages
                                                        .indexWhere((item) =>
                                                            item.id ==
                                                            groupModel
                                                                .replay!['id']);
                                                    indexed == -1
                                                        ? Fluttertoast.showToast(
                                                            msg: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .messagedeleted)
                                                        : scrollController
                                                            .scrollTo(
                                                                index: indexed,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1));
                                                  },
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: 250,
                                                        minWidth: 100),
                                                    height: 55,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        deftext(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .answered,
                                                            size: 10),
                                                        deftext(
                                                            text: groupModel.replay![
                                                                        'image'] !=
                                                                    null
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .picture
                                                                : groupModel.replay![
                                                                            'recorde'] !=
                                                                        null
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .audiorecording
                                                                    : groupModel.replay!['document'] !=
                                                                            null
                                                                        ? groupModel.replay![
                                                                            'document']
                                                                        : groupModel.replay![
                                                                            'message'],
                                                            size: 16,
                                                            maxlines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isdark(
                                                          trueco: Colors.grey
                                                              .withOpacity(0.3),
                                                          falseco: Colors.grey
                                                              .withOpacity(
                                                                  0.1)),
                                                      borderRadius:
                                                          BorderRadiusDirectional
                                                              .circular(10),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                          ReadMoreText(
                                            groupModel.message!,
                                            style: TextStyle(
                                              color: isdark(
                                                  trueco: HexColor('404040'),
                                                  falseco: HexColor('D1CDCD')),
                                            ),
                                            trimLines: 4,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText:
                                                AppLocalizations.of(context)!
                                                    .readmore,
                                            trimExpandedText:
                                                AppLocalizations.of(context)!
                                                    .showless,
                                            moreStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                        maxWidth: 250, minWidth: 20),
                                    decoration: BoxDecoration(
                                      color: isdark(
                                          trueco: HexColor('F0F0F0'),
                                          falseco: HexColor('373636')),
                                      borderRadius:
                                          BorderRadiusDirectional.only(
                                              bottomStart: Radius.circular(10),
                                              topEnd: Radius.circular(10),
                                              bottomEnd: Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isdark(
                                              falseco: HexColor('1A1A1A'),
                                              trueco: Colors.grey),

                                          spreadRadius: 2,

                                          blurRadius: 3,

                                          offset: Offset(1, 4), // ion of shadow
                                        ),
                                      ],
                                    ),
                                  ),
                        SizedBox(
                          height: 3,
                        ),
                        deftext(
                            text:
                                "${DateFormat.jm().format(DateTime.parse(groupModel.time!))}",
                            size: 12)
                      ],
                    ),
            ],
          ),
        ),
      ),
    );

Widget buttonbottomsheet(
        {required IconData icon,
        required String text,
        required Function()? ontap}) =>
    InkWell(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: 50,
          child: Row(
            children: [
              SizedBox(
                width: 30,
              ),
              Icon(
                icon,
                color: isdark(
                    trueco: HexColor('959595'), falseco: HexColor('959595')),
              ),
              SizedBox(
                width: 40,
              ),
              deftext(text: text, size: 14)
            ],
          ),
        ),
      ),
    );

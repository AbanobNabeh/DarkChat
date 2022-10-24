import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/model/messagemodel.dart';
import 'package:darkchat/view/screen/chat/PDFview.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timeago/timeago.dart';
import '../../../model/usermodel.dart';

class ChatScreen extends StatelessWidget {
  String phonenumber;
  ChatScreen({required this.phonenumber});
  TextEditingController message = TextEditingController();
  var formstate = GlobalKey<FormState>();
  var scaffoldstate = GlobalKey<ScaffoldState>();
  FocusNode focusNode = FocusNode();
  ItemScrollController scrollController = ItemScrollController();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitChat()..checkblockme(phonenumber),
      child: Builder(builder: (context) {
        CubitChat.get(context).getMessages(receiverId: phonenumber);
        CubitChat.get(context).isseen(phonenumber: phonenumber);
        CubitChat.get(context).getuser(phonenumber: phonenumber);
        CubitChat.get(context).initstate();
        CubitChat.get(context).checkblockme(phonenumber);
        return BlocConsumer<CubitChat, StatesChat>(
          builder: (context, state) => ConditionalBuilder(
            condition: state is GetUseerLoading || state is CheckBlocMELoading,
            builder: (context) => Center(
              child: defCircular(),
            ),
            fallback: (context) => Scaffold(
              key: scaffoldstate,
              appBar: AppBar(
                leading: BackButton(),
                centerTitle: false,
                title: InkWell(
                  onTap: () {
                    navto(
                        context: context,
                        screen: ProfileUserScreen(phonenumber));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: HexColor('F4A135').withOpacity(0.3),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              CubitChat.get(context).userchat['image']!),
                        ),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          deftext(
                              text: CubitChat.get(context).userchat['name']!,
                              size: 15),
                          state is GetUseerLoading
                              ? LinearProgressIndicator()
                              : Text(
                                  CubitChat.get(context).userchat['state'] ==
                                          'online'
                                      ? trans.online
                                      : CubitChat.get(context)
                                          .userchat['state'],
                                  style: TextStyle(fontSize: 12),
                                )
                        ],
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
                  child: Column(children: [
                    state is GetUseerLoading
                        ? LinearProgressIndicator()
                        : Container(
                            width: double.infinity,
                            height: 20,
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  CubitChat.get(context).userchat['bio']!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isdark(
                                          trueco: HexColor("FAFAFA"),
                                          falseco: HexColor("404040"))),
                                )),
                            color: isdark(
                                trueco: HexColor("404040"),
                                falseco: HexColor("FAFAFA")),
                          ),
                    Expanded(
                      child: ConditionalBuilder(
                        condition: state is GetMessageLoading,
                        builder: (context) => Center(child: defCircular()),
                        fallback: (context) => ConditionalBuilder(
                          condition: state is GetMessageLoading,
                          builder: (context) => Center(
                            child: defCircular(),
                          ),
                          fallback: (context) =>
                              ScrollablePositionedList.separated(
                            reverse: true,
                            itemScrollController: scrollController,
                            itemCount: CubitChat.get(context).message.length,
                            itemBuilder: ((context, index) {
                              var cubit = CubitChat.get(context).message;
                              if (index == cubit.length - 1) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: deftext(
                                        text:
                                            "${cubit[index].datetime!.substring(0, 11)}",
                                        size: 14,
                                      ),
                                    ),
                                    CubitChat.get(context)
                                                .message[index]
                                                .idreceived ==
                                            phonenumber
                                        ? SwipeTo(
                                            child: receivermessage(
                                                CubitChat.get(context)
                                                    .message[index],
                                                context,
                                                index,
                                                scaffoldstate,
                                                scrollController),
                                          )
                                        : sendermessage(
                                            CubitChat.get(context)
                                                .message[index],
                                            context,
                                            index,
                                            scaffoldstate,
                                            scrollController),
                                  ],
                                );
                              } else {
                                if (cubit[index].datetime!.substring(0, 11) ==
                                    cubit[index + 1]
                                        .datetime!
                                        .substring(0, 11)) {
                                  if (CubitChat.get(context)
                                          .message[index]
                                          .idreceived ==
                                      phonenumber) {
                                    return receivermessage(
                                        CubitChat.get(context).message[index],
                                        context,
                                        index,
                                        scaffoldstate,
                                        scrollController);
                                  } else {
                                    return sendermessage(
                                        CubitChat.get(context).message[index],
                                        context,
                                        index,
                                        scaffoldstate,
                                        scrollController);
                                  }
                                } else {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: deftext(
                                          text:
                                              "${cubit[index].datetime!.substring(0, 11)}",
                                          size: 14,
                                        ),
                                      ),
                                      CubitChat.get(context)
                                                  .message[index]
                                                  .idreceived ==
                                              phonenumber
                                          ? receivermessage(
                                              CubitChat.get(context)
                                                  .message[index],
                                              context,
                                              index,
                                              scaffoldstate,
                                              scrollController)
                                          : sendermessage(
                                              CubitChat.get(context)
                                                  .message[index],
                                              context,
                                              index,
                                              scaffoldstate,
                                              scrollController),
                                    ],
                                  );
                                }
                              }
                            }),
                            separatorBuilder: ((context, index) => Container()),
                          ),
                        ),
                      ),
                    ),
                    CubitChat.get(context).image != null
                        ? Image(image: FileImage(CubitChat.get(context).image!))
                        : SizedBox(),
                    SizedBox(
                      height: 5,
                    ),
                    CubitChat.get(context).block == true ||
                            CubitChat.get(context).meblock == true
                        ? Container(
                            height: 40,
                            width: double.infinity,
                            color: Colors.grey[600],
                            child: Center(
                              child: deftext(
                                  text: trans.personavailable,
                                  size: 12,
                                  textalign: TextAlign.center,
                                  color: Colors.white),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: defcolor.withOpacity(0.5),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isdark(
                                        trueco: HexColor("FFFFFF"),
                                        falseco: HexColor("CCCCCC")),
                                    child: IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return BlocProvider(
                                                create: (context) =>
                                                    CubitChat(),
                                                child: BlocConsumer<CubitChat,
                                                    StatesChat>(
                                                  builder: (context, state) {
                                                    return Container(
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
                                                                    ontap: () {
                                                                      CubitChat.get(context).requestPermissioncamera(
                                                                          context:
                                                                              context,
                                                                          phonenumber:
                                                                              phonenumber);
                                                                    }),
                                                                buttonbottomsheet(
                                                                    icon: NIcons
                                                                        .picture,
                                                                    text: trans
                                                                        .mobileLibrary,
                                                                    ontap: () {
                                                                      CubitChat.get(context).requestPermissiongallery(
                                                                          context:
                                                                              context,
                                                                          phonenumber:
                                                                              phonenumber);
                                                                    }),
                                                                buttonbottomsheet(
                                                                    icon: NIcons
                                                                        .doc_text,
                                                                    text: trans
                                                                        .document,
                                                                    ontap: () {
                                                                      CubitChat.get(
                                                                              context)
                                                                          .filepicker(
                                                                        context:
                                                                            context,
                                                                        phonenumber:
                                                                            phonenumber,
                                                                      );
                                                                    }),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 20,
                                                                vertical: 10,
                                                              ),
                                                              child: defbutton(
                                                                  text: trans
                                                                      .cancel,
                                                                  ontap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  })),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  listener: (context, state) {},
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
                                  child: CubitChat.get(context).isRecording ==
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
                                                      CubitChat.get(context)
                                                          .removerecord();
                                                    },
                                                    icon: Icon(NIcons.trash,
                                                        color: Colors.red)),
                                                CubitChat.get(context)
                                                    .buildTimer(),
                                                state is StopRecordingStateLoading
                                                    ? defCircular()
                                                    : IconButton(
                                                        onPressed: () {
                                                          CubitChat.get(context).stop(
                                                              message:
                                                                  message.text,
                                                              phonenumber:
                                                                  phonenumber,
                                                              name: CubitChat.get(
                                                                          context)
                                                                      .userchat[
                                                                  'name'],
                                                              imageuser: CubitChat
                                                                          .get(
                                                                              context)
                                                                      .userchat[
                                                                  'image'],
                                                              context: context);
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
                                              CubitChat.get(context)
                                                          .replaymessage ==
                                                      null
                                                  ? SizedBox()
                                                  : Container(
                                                      height: 55,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
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
                                                          CubitChat.get(context)
                                                                          .replaymessage![
                                                                      'image'] !=
                                                                  null
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          3.0),
                                                                  child: Image(
                                                                      image: NetworkImage(
                                                                          CubitChat.get(context)
                                                                              .replaymessage!['image'])),
                                                                )
                                                              : SizedBox(),
                                                          Text(
                                                            "|",
                                                            style: TextStyle(
                                                                fontSize: 35),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          3),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  deftext(
                                                                      text: CubitChat.get(
                                                                              context)
                                                                          .userchat['name'],
                                                                      size: 12),
                                                                  SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  deftext(
                                                                      text: CubitChat.get(context).replaymessage!['image'] !=
                                                                              null
                                                                          ? trans
                                                                              .pictures
                                                                          : CubitChat.get(context).replaymessage!['document'] != null
                                                                              ? CubitChat.get(context).replaymessage!['document']
                                                                              : CubitChat.get(context).replaymessage!['recorde'] != null
                                                                                  ? trans.audiorecording
                                                                                  : CubitChat.get(context).replaymessage!['name'],
                                                                      size: 12),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                              onPressed: () {
                                                                CubitChat.get(
                                                                        context)
                                                                    .removereplay();
                                                              },
                                                              icon: Icon(
                                                                Icons.close,
                                                                color: defcolor,
                                                                size: 20,
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                              TextFormField(
                                                focusNode: focusNode,
                                                onTap: () {
                                                  CubitChat.get(context)
                                                              .emojihide ==
                                                          true
                                                      ? null
                                                      : CubitChat.get(context)
                                                          .emoji();
                                                },
                                                controller: message,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "";
                                                  }
                                                },
                                                onChanged: (value) {
                                                  CubitChat.get(context)
                                                      .istype(value);
                                                },
                                                decoration: InputDecoration(
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                  errorStyle:
                                                      TextStyle(fontSize: 0),
                                                  hintText: trans.writemessage,
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
                                                      CubitChat.get(context)
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
                                                  suffixIcon:
                                                      CubitChat.get(context)
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
                                                                  CubitChat.get(context).messagedata(
                                                                      message:
                                                                          message
                                                                              .text,
                                                                      phonenumber:
                                                                          phonenumber,
                                                                      name: CubitChat.get(context)
                                                                              .userchat[
                                                                          'name'],
                                                                      imageuser:
                                                                          CubitChat.get(context).userchat[
                                                                              'image'],
                                                                      context:
                                                                          context);
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
                                                                CubitChat.get(
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
                    emoji(message, context, CubitChat.get(context).emojihide),
                  ]),
                ),
              ),
            ),
          ),
          listener: (context, state) {
            if (state is GetMessageSuccess) {
              CubitChat.get(context).isseen(phonenumber: phonenumber);
            }
          },
        );
      }),
    );
  }
}

Widget receivermessage(
    MessageModel messageModel,
    context,
    int index,
    GlobalKey<ScaffoldState> scaffoldstate,
    ItemScrollController scrollController) {
  GlobalKey widgetKey = GlobalKey();
  return SwipeTo(
    onLeftSwipe: () {
      CubitChat.get(context).replay({
        "name": messageModel.message,
        "id": messageModel.idmessage,
        "image": messageModel.messageimage,
        "recorde": messageModel.messagerecord,
        "document":
            messageModel.document != null ? messageModel.document!.name : null
      });
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        index == 0
            ? messageModel.seen == false
                ? Icon(
                    Icons.check_circle,
                    size: 16,
                    color: defcolor,
                  )
                : Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(
                          CubitChat.get(context).userchat['image']),
                    ),
                  )
            : SizedBox(),
        InkWell(
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
                                  CubitChat.get(context).deletemessage(
                                      context: context,
                                      phonenumber: messageModel.idreceived!,
                                      idmessage: messageModel.idmessage!,
                                      forme: 1);
                                },
                                child: deftext(
                                    text:
                                        "${AppLocalizations.of(context)!.deleteforme}",
                                    size: 12),
                              ),
                              TextButton(
                                onPressed: () {
                                  CubitChat.get(context).deletemessage(
                                      context: context,
                                      phonenumber: messageModel.idreceived!,
                                      idmessage: messageModel.idmessage!,
                                      forme: 2);
                                },
                                child: deftext(
                                    text:
                                        "${AppLocalizations.of(context)!.deleteforeveryone}",
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
                      Expanded(
                        child: bottomshetmessage(() {
                          Clipboard.setData(
                                  ClipboardData(text: messageModel.message))
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
                      messageModel.messageimage != null
                          ? Expanded(
                              child: bottomshetmessage(() {
                                CubitChat.get(context).savephoto(
                                    "${messageModel.messageimage}", context);
                              }, Icon(NIcons.download, color: defcolor),
                                  AppLocalizations.of(context)!.savePhoto),
                            )
                          : SizedBox(),
                    ],
                  ),
                ));
          },
          child: Align(
            key: widgetKey,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: messageModel.messageimage == null
                  ? messageModel.messagerecord == null
                      ? messageModel.document == null
                          ? Container(
                              constraints:
                                  BoxConstraints(maxWidth: 250, minWidth: 100),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: InkWell(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      messageModel.replay != null
                                          ? InkWell(
                                              onTap: () {
                                                var indexed =
                                                    CubitChat.get(context)
                                                        .message
                                                        .indexWhere((item) =>
                                                            item.idmessage ==
                                                            messageModel
                                                                .replay!['id']);
                                                indexed == -1
                                                    ? Fluttertoast.showToast(
                                                        msg:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .messagedeleted)
                                                    : scrollController.scrollTo(
                                                        index: indexed,
                                                        duration: Duration(
                                                            seconds: 1));
                                              },
                                              child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: 250,
                                                    minWidth: 100),
                                                height: 55,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
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
                                                          text: messageModel
                                                                          .replay![
                                                                      'image'] !=
                                                                  null
                                                              ? AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .picture
                                                              : messageModel.replay![
                                                                          'recorde'] !=
                                                                      null
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .audiorecording
                                                                  : messageModel.replay![
                                                                              'document'] !=
                                                                          null
                                                                      ? messageModel
                                                                              .replay![
                                                                          'document']
                                                                      : messageModel
                                                                              .replay![
                                                                          'name'],
                                                          size: 16,
                                                          maxlines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis)
                                                    ],
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isdark(
                                                      trueco: Colors.grey
                                                          .withOpacity(0.3),
                                                      falseco: Colors.grey
                                                          .withOpacity(0.1)),
                                                  borderRadius:
                                                      BorderRadiusDirectional
                                                          .circular(10),
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      ReadMoreText(
                                        "${messageModel.message}",
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
                                      deftext(
                                          text:
                                              "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                                          size: 12)
                                    ],
                                  ),
                                ),
                              ),
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
                            )
                          : InkWell(
                              onTap: () {
                                navto(
                                    context: context,
                                    screen:
                                        PDFviewScreen(messageModel.document!));
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
                                              text:
                                                  messageModel.document!.name!,
                                              size: 14,
                                              overflow: TextOverflow.ellipsis,
                                              maxlines: 1),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: isdark(
                                              trueco:
                                                  Colors.grey.withOpacity(0.5),
                                              falseco: Colors.black54
                                                  .withOpacity(0.5)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          deftext(
                                              text:
                                                  "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                                              size: 12),
                                          deftext(
                                              text: CubitChat.get(context)
                                                  .formatSizefile(
                                                      messageModel
                                                          .document!.bytes!,
                                                      context),
                                              size: 12),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                          falseco: HexColor("CCCCCC")),
                                      child: IconButton(
                                        onPressed: () {
                                          CubitChat.get(context).isplaying(
                                              messageModel.messagerecord);
                                        },
                                        padding: EdgeInsets.zero,
                                        icon: CubitChat.get(context).playlist[
                                                messageModel.messagerecord]
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
                                        max: CubitChat.get(context).playlist[
                                                messageModel.messagerecord]
                                            ? CubitChat.get(context)
                                                .duration
                                                .inSeconds
                                                .toDouble()
                                            : 0,
                                        value: CubitChat.get(context).playlist[
                                                messageModel.messagerecord]
                                            ? CubitChat.get(context)
                                                .position
                                                .inSeconds
                                                .toDouble()
                                            : 0,
                                        onChanged: (value) {
                                          CubitChat.get(context).playlist[
                                                      messageModel
                                                          .messagerecord] ==
                                                  true
                                              ? CubitChat.get(context)
                                                  .slideronchange(value)
                                              : null;
                                        },
                                        activeColor: defcolor),
                                    deftext(
                                        text: CubitChat.get(context).playlist[
                                                messageModel.messagerecord]
                                            ? CubitChat.get(context).formatTime(
                                                CubitChat.get(context).position)
                                            : "00:00",
                                        size: 12)
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: isdark(
                                      trueco: HexColor('F0F0F0'),
                                      falseco: HexColor('474747')),
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: deftext(
                                  text:
                                      "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                                  size: 12),
                            )
                          ],
                        )
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              scaffoldstate.currentState!.showBottomSheet(
                                (context) => PhotoViewGallery(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  pageOptions: [
                                    PhotoViewGalleryPageOptions(
                                      imageProvider: NetworkImage(
                                          CubitChat.get(context)
                                              .message[index]
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
                                  maxHeight: 200,
                                  maxWidth: 200,
                                  minHeight: 80),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadiusDirectional.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          messageModel.messageimage!),
                                      fit: BoxFit.fill)),
                            ),
                          ),
                          messageModel.message != ""
                              ? Container(
                                  constraints: BoxConstraints(
                                      minWidth: 15, maxWidth: 200),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: ReadMoreText(
                                      messageModel.message!,
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
                                  ))
                              : SizedBox(),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: deftext(
                              text:
                                  "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                              size: 12,
                              color: isdark(
                                  trueco: HexColor('404040'),
                                  falseco: HexColor('D1CDCD')),
                            ),
                          )
                        ],
                      ),
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
                      )),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget sendermessage(
    MessageModel messageModel,
    context,
    int index,
    GlobalKey<ScaffoldState> scaffoldstate,
    ItemScrollController scrollController) {
  return SwipeTo(
    onLeftSwipe: () {
      CubitChat.get(context).replay({
        "name": messageModel.message,
        "id": messageModel.idmessage,
        "image": messageModel.messageimage,
        "recorde": messageModel.messagerecord,
        "document":
            messageModel.document != null ? messageModel.document!.name : null
      });
    },
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
                              CubitChat.get(context).deletemessage(
                                  context: context,
                                  phonenumber: messageModel.idsender!,
                                  idmessage: messageModel.idmessage!,
                                  forme: 1);
                            },
                            child: deftext(
                                text:
                                    "${AppLocalizations.of(context)!.deleteforme}",
                                size: 12),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: deftext(
                                text: "${AppLocalizations.of(context)!.cancel}",
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
                  Expanded(
                    child: bottomshetmessage(() {
                      Clipboard.setData(
                              ClipboardData(text: messageModel.message))
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.messagecopied);
                        Navigator.pop(context);
                      });
                    },
                        Icon(
                          NIcons.doc_text,
                          color: Colors.blue,
                        ),
                        AppLocalizations.of(context)!.copy),
                  ),
                  messageModel.messageimage != null
                      ? Expanded(
                          child: bottomshetmessage(() {
                            CubitChat.get(context).savephoto(
                                "${messageModel.messageimage}", context);
                          }, Icon(NIcons.download, color: defcolor),
                              AppLocalizations.of(context)!.savePhoto),
                        )
                      : SizedBox(),
                ],
              ),
            ));
      },
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: messageModel.messageimage == null
                ? messageModel.messagerecord == null
                    ? messageModel.document == null
                        ? Container(
                            constraints:
                                BoxConstraints(maxWidth: 250, minWidth: 100),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    messageModel.replay != null
                                        ? InkWell(
                                            onTap: () {
                                              var indexed =
                                                  CubitChat.get(context)
                                                      .message
                                                      .indexWhere((item) =>
                                                          item.idmessage ==
                                                          messageModel
                                                              .replay!['id']);
                                              indexed == -1
                                                  ? Fluttertoast.showToast(
                                                      msg: AppLocalizations.of(
                                                              context)!
                                                          .messagedeleted)
                                                  : scrollController.scrollTo(
                                                      index: indexed,
                                                      duration:
                                                          Duration(seconds: 1));
                                            },
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: 250, minWidth: 100),
                                              height: 55,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    deftext(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .answered,
                                                        size: 10,
                                                        color: Colors.white),
                                                    deftext(
                                                        text: messageModel
                                                                        .replay![
                                                                    'image'] !=
                                                                null
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .picture
                                                            : messageModel.replay![
                                                                        'recorde'] !=
                                                                    null
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .audiorecording
                                                                : messageModel.replay![
                                                                            'document'] !=
                                                                        null
                                                                    ? messageModel
                                                                            .replay![
                                                                        'document']
                                                                    : messageModel
                                                                            .replay![
                                                                        'name'],
                                                        size: 16,
                                                        maxlines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.white)
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: isdark(
                                                    trueco: Colors.grey
                                                        .withOpacity(0.3),
                                                    falseco: Colors.grey
                                                        .withOpacity(0.4)),
                                                borderRadius:
                                                    BorderRadiusDirectional
                                                        .circular(10),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    ReadMoreText(
                                      "${messageModel.message}",
                                      style: TextStyle(
                                        color: Colors.white,
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
                                    deftext(
                                      text:
                                          "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
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
                                    offset: Offset(1, 4), // ion of shadow
                                  ),
                                ],
                                color: defcolor,
                                borderRadius: BorderRadiusDirectional.only(
                                    topEnd: Radius.circular(10),
                                    topStart: Radius.circular(10),
                                    bottomStart: Radius.circular(10))),
                          )
                        : InkWell(
                            onTap: () {
                              navto(
                                  context: context,
                                  screen:
                                      PDFviewScreen(messageModel.document!));
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: defcolor,
                                borderRadius: BorderRadiusDirectional.only(
                                    topEnd: Radius.circular(10),
                                    topStart: Radius.circular(10),
                                    bottomStart: Radius.circular(10)),
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
                                            text: messageModel.document!.name!,
                                            size: 14,
                                            overflow: TextOverflow.ellipsis,
                                            maxlines: 1,
                                            color: Colors.white),
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: HexColor('704000')
                                              .withOpacity(0.2)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        deftext(
                                            text: CubitChat.get(context)
                                                .formatSizefile(
                                                    messageModel
                                                        .document!.bytes!,
                                                    context),
                                            size: 12,
                                            color: Colors.white),
                                        deftext(
                                            text:
                                                "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
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
                                        falseco: HexColor("CCCCCC")),
                                    child: IconButton(
                                      onPressed: () {
                                        CubitChat.get(context).isplaying(
                                            messageModel.messagerecord);
                                      },
                                      padding: EdgeInsets.zero,
                                      icon: CubitChat.get(context).playlist[
                                              messageModel.messagerecord]
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
                                      thumbColor: Colors.white,
                                      inactiveColor: HexColor('D28A2C'),
                                      max: CubitChat.get(context).playlist[
                                              messageModel.messagerecord]
                                          ? CubitChat.get(context)
                                              .duration
                                              .inSeconds
                                              .toDouble()
                                          : 0,
                                      value: CubitChat.get(context).playlist[
                                              messageModel.messagerecord]
                                          ? CubitChat.get(context)
                                              .position
                                              .inSeconds
                                              .toDouble()
                                          : 0,
                                      onChanged: (value) {
                                        CubitChat.get(context).playlist[
                                                messageModel.messagerecord]
                                            ? CubitChat.get(context)
                                                .slideronchange(value)
                                            : null;
                                      },
                                      activeColor: Colors.white),
                                  deftext(
                                      text: CubitChat.get(context).playlist[
                                              messageModel.messagerecord]
                                          ? CubitChat.get(context).formatTime(
                                              CubitChat.get(context).position)
                                          : "00:00",
                                      size: 12,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: defcolor,
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: deftext(
                                text:
                                    "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                                size: 12),
                          )
                        ],
                      )
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            scaffoldstate.currentState!.showBottomSheet(
                              (context) => PhotoViewGallery(
                                scrollPhysics: const BouncingScrollPhysics(),
                                pageOptions: [
                                  PhotoViewGalleryPageOptions(
                                    imageProvider: NetworkImage(
                                        CubitChat.get(context)
                                            .message[index]
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
                                maxHeight: 200,
                                maxWidth: 200,
                                minHeight: 80),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.vertical(
                                  top: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        messageModel.messageimage!),
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        messageModel.message != ""
                            ? Container(
                                constraints: BoxConstraints(
                                  minWidth: 15,
                                  maxWidth: 200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ReadMoreText(
                                    messageModel.message!,
                                    style: TextStyle(
                                      color: isdark(
                                          trueco: HexColor('404040'),
                                          falseco: HexColor('D1CDCD')),
                                    ),
                                    trimLines: 4,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText:
                                        AppLocalizations.of(context)!.readmore,
                                    trimExpandedText:
                                        AppLocalizations.of(context)!.showless,
                                    moreStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ))
                            : SizedBox(
                                width: 0,
                              ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: deftext(
                            text:
                                "${DateFormat.jm().format(DateTime.parse(messageModel.datetime!))}",
                            size: 12,
                            color: isdark(
                                trueco: HexColor('404040'),
                                falseco: HexColor('D1CDCD')),
                          ),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: defcolor,
                        borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(10),
                            topStart: Radius.circular(10),
                            bottomStart: Radius.circular(10))))),
      ),
    ),
  );
}

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

bottomshetmessage(ontap, icon, text) => InkWell(
      onTap: ontap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(text),
        ],
      ),
    );

import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/model/chatlistmodel.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:darkchat/model/usermodel.dart';
import 'package:darkchat/view/screen/chat/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:hexcolor/hexcolor.dart';

class ChatListScreen extends StatelessWidget {
  var scafoldstate = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitChat()..getuserschat(),
      child: Builder(builder: (context) {
        CubitChat.get(context).getuserschat();
        return OfflineBuilder(
          connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
            final bool connected = connectivity != ConnectivityResult.none;
            return Stack(
              fit: StackFit.expand,
              children: [child, oflline(connected, context)],
            );
          },
          child: BlocConsumer<CubitChat, StatesChat>(
            builder: (context, state) => Scaffold(
              key: scafoldstate,
              body: SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isdark(
                                  trueco: HexColor('EEECEC'),
                                  falseco: HexColor('454545'))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TabBar(
                              indicator: BoxDecoration(
                                  color: isdark(
                                      trueco: HexColor('FFFFFF'),
                                      falseco: HexColor('595959')),
                                  borderRadius: BorderRadius.circular(8)),
                              tabs: [
                                deftext(
                                  text: AppLocalizations.of(context)!.chatting,
                                  size: 15,
                                ),
                                deftext(
                                    text: AppLocalizations.of(context)!
                                        .publications,
                                    size: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          ListView.separated(
                            itemCount: CubitChat.get(context).chatlist.length,
                            itemBuilder: (context, index) {
                              return listchat(
                                  CubitChat.get(context).chatlist[index], () {
                                navto(
                                    context: context,
                                    screen: ChatScreen(
                                        phonenumber: CubitChat.get(context)
                                            .chatlist[index]
                                            .phonenumber!));
                              }, context, scafoldstate);
                            },
                            separatorBuilder: (context, index) {
                              return defDiv();
                            },
                          ),
                          Center(
                            child: deftext(
                                text: AppLocalizations.of(context)!.soonafter,
                                size: 16),
                          )
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
            listener: (context, state) {},
          ),
        );
      }),
    );
  }
}

Widget listchat(ChatListModel chatListModel, onTap, context,
        GlobalKey<ScaffoldState> scaffoldstate) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SwipeActionCell(
        key: ValueKey(chatListModel),
        trailingActions: [
          SwipeAction(
              title: AppLocalizations.of(context)!.delete,
              performsFirstActionWithFullSwipe: true,
              nestedAction: SwipeNestedAction(
                  title: AppLocalizations.of(context)!.confirm),
              onTap: (handler) async {
                CubitHome.get(context).deletechat(chatListModel.phonenumber!);
              }),
          SwipeAction(
              title: chatListModel.seen == false
                  ? AppLocalizations.of(context)!.read
                  : AppLocalizations.of(context)!.unread,
              color: Colors.grey,
              onTap: (handler) {
                chatListModel.seen == false
                    ? CubitHome.get(context)
                        .unreadchat(chatListModel.phonenumber!)
                    : CubitHome.get(context)
                        .readchat(chatListModel.phonenumber!);
              }),
        ],
        leadingActions: [
          SwipeAction(
              title: AppLocalizations.of(context)!.more,
              onTap: (handler) async {
                navto(
                    context: context,
                    screen: ProfileUserScreen(chatListModel.phonenumber!));
              }),
        ],
        child: InkWell(
          onLongPress: () {
            navto(
                context: context,
                screen: ProfileUserScreen(chatListModel.phonenumber!));
          },
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(chatListModel.imageuser!))),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    deftext(text: chatListModel.name!, size: 16),
                    Container(
                      child: chatListModel.seen == false
                          ? chatListModel.messageimage != null
                              ? Image(
                                  image:
                                      NetworkImage(chatListModel.messageimage!),
                                  width: 30,
                                  height: 30,
                                )
                              : deftext(
                                  text: chatListModel.recored != null
                                      ? chatListModel.recored!
                                      : chatListModel.document != null
                                          ? chatListModel.document!
                                          : chatListModel.lastmessage!,
                                  size: 16,
                                  color: defcolor,
                                  maxlines: 1,
                                  overflow: TextOverflow.ellipsis)
                          : chatListModel.messageimage != null
                              ? Image(
                                  image:
                                      NetworkImage(chatListModel.messageimage!),
                                  width: 30,
                                  height: 30,
                                )
                              : deftext(
                                  text: chatListModel.recored != null
                                      ? chatListModel.recored!
                                      : chatListModel.document != null
                                          ? chatListModel.document!
                                          : chatListModel.lastmessage!,
                                  size: 16,
                                  color: isdark(
                                      trueco: Colors.black.withOpacity(0.5),
                                      falseco: Colors.white.withOpacity(0.5)),
                                  fontWeight: FontWeight.normal,
                                  maxlines: 1,
                                  overflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  deftext(
                      text: CubitChat.get(context).convertToAgo(
                          DateTime.parse(chatListModel.datatime!), context),
                      size: 12),
                  chatListModel.seen == false
                      ? CircleAvatar(
                          radius: 5,
                          backgroundColor: defcolor,
                        )
                      : SizedBox(
                          width: 0,
                        )
                ],
              )
            ],
          ),
        ),
      ),
    );

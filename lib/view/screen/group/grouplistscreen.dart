import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:darkchat/model/grouplistmodel.dart';
import 'package:darkchat/view/screen/group/createnewgroup.dart';
import 'package:darkchat/view/screen/group/groupdetails.dart';
import 'package:darkchat/view/screen/group/groupscreen.dart';
import 'package:darkchat/view/screen/group/requestgroup.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup()..getGroups(),
      child: Builder(builder: (context) {
        CubitGroup.get(context).getGroups();
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
          child: BlocConsumer<CubitGroup, StatesGroup>(
            listener: (context, state) {},
            builder: (context, state) => Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CubitGroup.get(context).requests.isEmpty
                            ? SizedBox(
                                width: 0,
                              )
                            : InkWell(
                                onTap: () {
                                  navto(
                                      context: context,
                                      screen: RequestGroupScreen());
                                },
                                child: Container(
                                  height: 45,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: deftext(
                                      text: CubitGroup.get(context)
                                          .requests
                                          .length
                                          .toString(),
                                      size: 16,
                                    )),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              navto(
                                  context: context,
                                  screen: CreateNewGroupScreen());
                            },
                            child: Container(
                              height: 45,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.group_add_rounded,
                                      color: isdark(
                                          trueco: HexColor("404040"),
                                          falseco: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    deftext(
                                        text: trans.createnewgroup, size: 12)
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isdark(
                                    trueco: HexColor("EEECEC"),
                                    falseco: HexColor("707070")),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: state is GetGroupsListLoading
                          ? Center(
                              child: defCircular(),
                            )
                          : ListView.separated(
                              itemBuilder: (context, index) {
                                return listgroup(
                                    CubitGroup.get(context).groups[index],
                                    context,
                                    index);
                              },
                              separatorBuilder: (context, index) {
                                return defDiv();
                              },
                              itemCount: CubitGroup.get(context).groups.length),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

Widget listgroup(ModelGroupList group, BuildContext context, index) => InkWell(
      onLongPress: () {
        navto(context: context, screen: GroupDetailsScreen(group.id!));
      },
      onTap: () {
        navto(context: context, screen: GroupScreen(group.id!));
      },
      child: Container(
        width: double.infinity,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(group.image!), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                deftext(
                    text: group.name!,
                    size: 16,
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis),
                group.messageimage == null
                    ? deftext(
                        text: group.messagerecord != null
                            ? group.messagerecord!
                            : group.document != null
                                ? group.document!
                                : group.lastmessage!,
                        size: 12,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis)
                    : Image(
                        image: NetworkImage(group.messageimage!),
                        width: 30,
                        height: 30,
                      ),
              ],
            )),
            Column(
              children: [
                deftext(
                    text: CubitGroup.get(context)
                        .convertToAgo(DateTime.parse(group.time!), context),
                    size: 14),
                CubitGroup.get(context).seen[group.id] == true
                    ? SizedBox()
                    : CircleAvatar(
                        radius: 5,
                        backgroundColor: defcolor,
                      )
              ],
            )
          ],
        ),
      ),
    );

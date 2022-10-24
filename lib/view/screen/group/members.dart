import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/view/screen/group/addmember.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class MembersScreen extends StatelessWidget {
  String idgroup;
  MembersScreen(this.idgroup);
  var scaffoldstate = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup()
        ..getmembers(idgroup)
        ..getprofilemember(idgroup),
      child: BlocConsumer<CubitGroup, StatesGroup>(
        builder: (context, state) => Scaffold(
          key: scaffoldstate,
          appBar: AppBar(
            title: Text(trans.members),
          ),
          floatingActionButton:
              CubitGroup.get(context).group['canadd'] == "admin"
                  ? CubitGroup.get(context).me['state'] == "member"
                      ? null
                      : FloatingActionButton(
                          onPressed: () {
                            navto(
                                context: context,
                                screen: AddMemberScreen(idgroup));
                          },
                          child: Icon(NIcons.plus),
                          backgroundColor: defcolor,
                        )
                  : CubitGroup.get(context).me['state'] != "leader"
                      ? null
                      : FloatingActionButton(
                          onPressed: () {
                            navto(
                                context: context,
                                screen: AddMemberScreen(idgroup));
                          },
                          child: Icon(NIcons.plus),
                          backgroundColor: defcolor,
                        ),
          body: state is GetProfileMemberLoading
              ? Center(child: defCircular())
              : ListView.separated(
                  itemBuilder: (context, index) => InkWell(
                        onTap: CubitGroup.get(context).profilemember[index]
                                    ['phonenumber'] ==
                                id
                            ? null
                            : CubitGroup.get(context).me['state'] == "member"
                                ? () {
                                    navto(
                                        context: context,
                                        screen: ProfileUserScreen(
                                            CubitGroup.get(context)
                                                    .profilemember[index]
                                                ['phonenumber']));
                                  }
                                : () {
                                    if (CubitGroup.get(context)
                                            .profilemember[index]['state'] ==
                                        "leader") {
                                      navto(
                                          context: context,
                                          screen: ProfileUserScreen(
                                              CubitGroup.get(context)
                                                      .profilemember[index]
                                                  ['phonenumber']));
                                    } else if (CubitGroup.get(context)
                                            .profilemember[index]['state'] ==
                                        "admin") {
                                      if (CubitGroup.get(context).me['state'] ==
                                          "leader") {
                                        scaffoldstate.currentState!
                                            .showBottomSheet((context) =>
                                                Container(
                                                  height: 80,
                                                  width: double.infinity,
                                                  color: isdark(
                                                      trueco:
                                                          HexColor("FAFAFA"),
                                                      falseco:
                                                          HexColor("404040")),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      state
                                                              is RemoveAdminLoading
                                                          ? defCircular()
                                                          : itembottomsheet(() {
                                                              CubitGroup.get(
                                                                      context)
                                                                  .removeadmin(
                                                                      idgroup:
                                                                          idgroup,
                                                                      id: CubitGroup.get(context)
                                                                              .profilemember[index]
                                                                          [
                                                                          'phonenumber']);
                                                            },
                                                              Icons
                                                                  .person_remove,
                                                              trans
                                                                  .removeadmin),
                                                      itembottomsheet(
                                                          () {},
                                                          NIcons.user,
                                                          trans.profile),
                                                    ],
                                                  ),
                                                ));
                                      } else {
                                        navto(
                                            context: context,
                                            screen: ProfileUserScreen(
                                                CubitGroup.get(context)
                                                        .profilemember[index]
                                                    ['phonenumber']));
                                      }
                                    } else if (CubitGroup.get(context)
                                            .profilemember[index]['state'] ==
                                        "member") {
                                      scaffoldstate.currentState!
                                          .showBottomSheet((context) =>
                                              Container(
                                                height: 80,
                                                width: double.infinity,
                                                color: isdark(
                                                    trueco: HexColor("FAFAFA"),
                                                    falseco:
                                                        HexColor("404040")),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    state is AddAdminLoading
                                                        ? defCircular()
                                                        : itembottomsheet(() {
                                                            CubitGroup.get(
                                                                    context)
                                                                .addadmin(
                                                              idgroup: idgroup,
                                                              id: CubitGroup.get(
                                                                          context)
                                                                      .profilemember[index]
                                                                  [
                                                                  'phonenumber'],
                                                            );
                                                          }, NIcons.user_plus,
                                                            trans.addadmin),
                                                    itembottomsheet(() {
                                                      CubitGroup.get(context).removemember(
                                                          idgroup: idgroup,
                                                          id: CubitGroup.get(
                                                                      context)
                                                                  .profilemember[index]
                                                              ['phonenumber'],
                                                          state: CubitGroup.get(
                                                                      context)
                                                                  .profilemember[
                                                              index]['state'],
                                                          context: context);
                                                    }, NIcons.user_times,
                                                        trans.removemember),
                                                    itembottomsheet(
                                                        () {},
                                                        NIcons.user,
                                                        trans.profile),
                                                  ],
                                                ),
                                              ));
                                    } else {
                                      scaffoldstate.currentState!
                                          .showBottomSheet((context) =>
                                              Container(
                                                height: 80,
                                                width: double.infinity,
                                                color: isdark(
                                                    trueco: HexColor("FAFAFA"),
                                                    falseco:
                                                        HexColor("404040")),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    itembottomsheet(() {
                                                      CubitGroup.get(context).removemember(
                                                          idgroup: idgroup,
                                                          id: CubitGroup.get(
                                                                      context)
                                                                  .profilemember[index]
                                                              ['phonenumber'],
                                                          state: CubitGroup.get(
                                                                      context)
                                                                  .profilemember[
                                                              index]['state'],
                                                          context: context);
                                                    }, NIcons.user_times,
                                                        trans.removemember),
                                                    itembottomsheet(
                                                        () {},
                                                        NIcons.user,
                                                        trans.profile),
                                                  ],
                                                ),
                                              ));
                                    }
                                  },
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              CubitGroup.get(context)
                                                      .profilemember[index]
                                                  ['image']))),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      deftext(
                                          text: CubitGroup.get(context)
                                              .profilemember[index]['name'],
                                          size: 16),
                                      deftext(
                                          text: CubitGroup.get(context)
                                                  .profilemember[index]
                                              ['phonenumber'],
                                          size: 12)
                                    ],
                                  ),
                                ),
                                deftext(
                                    text: CubitGroup.get(context)
                                                    .profilemember[index]
                                                ['state'] ==
                                            "leader"
                                        ? trans.leader
                                        : CubitGroup.get(context)
                                                        .profilemember[index]
                                                    ['state'] ==
                                                "admin"
                                            ? trans.admin
                                            : CubitGroup.get(context)
                                                            .profilemember[
                                                        index]['state'] ==
                                                    "member"
                                                ? trans.member
                                                : trans.request,
                                    size: 12)
                              ],
                            ),
                          ),
                        ),
                      ),
                  separatorBuilder: (context, index) {
                    return defDiv();
                  },
                  itemCount: CubitGroup.get(context).profilemember.length),
        ),
        listener: (context, state) {
          if (state is AddAdminSuccess ||
              state is RemoveAdminSuccess ||
              state is RemoveMemberSuccess) {
            Navigator.pop(context, 'cancel');
          }
        },
      ),
    );
  }
}

Widget itembottomsheet(ontap, icon, text) => InkWell(
      onTap: ontap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isdark(
                trueco: Colors.black,
                falseco: Colors.white,
              )),
          deftext(text: text, size: 12)
        ],
      ),
    );

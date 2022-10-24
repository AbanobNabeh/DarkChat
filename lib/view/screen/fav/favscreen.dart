import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/constants.dart';

class FAVSacreen extends StatelessWidget {
  const FAVSacreen({super.key});

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitHome, StatesHome>(
      builder: (context, state) {
        var cubit = CubitHome.get(context).MyFav;
        var hiscubit = CubitHome.get(context).HisFav;
        return Scaffold(
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
                              text: trans.myfav,
                              size: 15,
                            ),
                            deftext(text: trans.hisfav, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Expanded(
                      child: TabBarView(
                    children: [
                      ListView.separated(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  navto(
                                      context: context,
                                      screen: ProfileUserScreen(
                                          cubit[index]['phonenumber']));
                                },
                                child: Container(
                                  child: Row(children: [
                                    Container(
                                      width: 50,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  cubit[index]['image']),
                                              fit: BoxFit.cover)),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          deftext(
                                              text: cubit[index]['name'],
                                              size: 16),
                                          deftext(
                                              text: cubit[index]['phonenumber'],
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                    cubit[index]['by'] == "1"
                                        ? deftext(
                                            text: cubit[index]['by'] == "1"
                                                ? "50%"
                                                : "100%",
                                            size: 16,
                                            color: defcolor)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              deftext(
                                                  text:
                                                      cubit[index]['by'] == "1"
                                                          ? "50%"
                                                          : "100%",
                                                  size: 16,
                                                  color: defcolor),
                                              Icon(
                                                NIcons.heart,
                                                color: Colors.red,
                                              )
                                            ],
                                          )
                                  ]),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => defDiv(),
                          itemCount: cubit.length),
                      ListView.separated(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: hiscubit[index]['by'] == "1"
                                    ? null
                                    : () {
                                        navto(
                                            context: context,
                                            screen: ProfileUserScreen(
                                                hiscubit[index]
                                                    ['phonenumber']));
                                      },
                                child: Container(
                                  child: Row(children: [
                                    Container(
                                      width: 50,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                              image: hiscubit[index]["by"] ==
                                                      "1"
                                                  ? NetworkImage(
                                                      "https://firebasestorage.googleapis.com/v0/b/darkchat-31673.appspot.com/o/heart.png?alt=media&token=462b04a8-c6a1-48de-81b6-1df41846c710")
                                                  : NetworkImage(
                                                      hiscubit[index]['image']),
                                              fit: BoxFit.cover)),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          hiscubit[index]['by'] == "1"
                                              ? deftext(
                                                  text: "UnKnow", size: 16)
                                              : deftext(
                                                  text: hiscubit[index]['name'],
                                                  size: 16),
                                          deftext(
                                              text: hiscubit[index]['by'] == "1"
                                                  ? "${hiscubit[index]['phonenumber'].substring(0, 4)}${'X' * (hiscubit[index]['phonenumber'].length - 6)}"
                                                  : hiscubit[index]
                                                      ['phonenumber'],
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                    hiscubit[index]['by'] == "1"
                                        ? deftext(
                                            text: hiscubit[index]['by'] == "1"
                                                ? "50%"
                                                : "100%",
                                            size: 16,
                                            color: defcolor)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              deftext(
                                                  text: hiscubit[index]['by'] ==
                                                          "1"
                                                      ? "50%"
                                                      : "100%",
                                                  size: 16,
                                                  color: defcolor),
                                              Icon(
                                                NIcons.heart,
                                                color: Colors.red,
                                              )
                                            ],
                                          )
                                  ]),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => defDiv(),
                          itemCount: hiscubit.length),
                    ],
                  ))
                ],
              ),
            ),
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}

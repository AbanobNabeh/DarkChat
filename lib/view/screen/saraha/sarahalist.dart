import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/cubit/cubitsaraha/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/states.dart';
import 'package:darkchat/model/sarahahmodel.dart';
import 'package:darkchat/view/screen/saraha/sarahadetails.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:readmore/readmore.dart';

import '../../../constants/constants.dart';

class SarahListScreen extends StatelessWidget {
  TextEditingController text = TextEditingController();

  TextEditingController comment = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitSaraha()..getmysarah(),
      child: Builder(builder: (context) {
        CubitSaraha.get(context).getmysarah();
        return BlocConsumer<CubitSaraha, StatesSaraha>(
          builder: (context, state) => Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: TextFormField(
                      controller: text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "";
                        }
                      },
                      onChanged: (value) {
                        CubitSaraha.get(context).omchangesearch(value);
                      },
                      decoration: InputDecoration(
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          errorStyle: TextStyle(fontSize: 0),
                          hintText: trans.search,
                          hintStyle: TextStyle(
                              color: isdark(
                                  trueco: HexColor('B4B3B3'),
                                  falseco: HexColor('959595'))),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            NIcons.search,
                            color: HexColor("404040"),
                          )),
                      cursorColor: defcolor,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isdark(
                          trueco: Colors.grey.withOpacity(0.3),
                          falseco: HexColor("CCCCCC")),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ConditionalBuilder(
                    condition: state is SearchSarahaLoading ||
                        state is GetMySarahaLoading,
                    builder: (context) => Center(
                      child: defCircular(),
                    ),
                    fallback: (context) => Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) => sarahlist(
                              CubitSaraha.get(context).mysaraha[index],
                              context),
                          separatorBuilder: (context, index) => SizedBox(
                                height: 10,
                              ),
                          itemCount: CubitSaraha.get(context).mysaraha.length),
                    ),
                  ),
                ],
              ),
            ),
          ),
          listener: (context, state) {},
        );
      }),
    );
  }
}

Widget sarahlist(SarahahModel sarahahModel, BuildContext context) => InkWell(
      onTap: () {
        navto(context: context, screen: SarahaDetailsScreen(sarahahModel.id!));
      },
      child: SwipeActionCell(
        key: ValueKey(sarahahModel),
        trailingActions: [
          SwipeAction(
              performsFirstActionWithFullSwipe: true,
              color: Colors.grey,
              title: sarahahModel.seen == false
                  ? AppLocalizations.of(context)!.read
                  : AppLocalizations.of(context)!.unread,
              onTap: (handler) async {
                sarahahModel.seen == false
                    ? CubitSaraha.get(context).readsaraha(sarahahModel.id!)
                    : CubitSaraha.get(context).unreadsaraha(sarahahModel.id!);
              }),
        ],
        leadingActions: [
          SwipeAction(
              performsFirstActionWithFullSwipe: true,
              color: Colors.red,
              onTap: (handler) {
                CubitSaraha.get(context).deletesaraha(sarahahModel.id!);
              },
              nestedAction: SwipeNestedAction(
                  title: AppLocalizations.of(context)!.confirm),
              title: AppLocalizations.of(context)!.delete),
        ],
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                isdark(trueco: HexColor("F0F0F0"), falseco: HexColor("474747")),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: isdark(falseco: HexColor('1A1A1A'), trueco: Colors.grey),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(1, 1), // ion of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                sarahahModel.image != null
                    ? Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: NetworkImage(sarahahModel.image!),
                                fit: BoxFit.cover)),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 3,
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: deftext(
                      text: sarahahModel.message!,
                      size: 16,
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis),
                )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    deftext(
                        text: CubitSaraha.get(context).convertToAgo(
                            DateTime.parse(sarahahModel.datetime!), context),
                        size: 12),
                    SizedBox(
                      height: 5,
                    ),
                    sarahahModel.seen == false
                        ? CircleAvatar(
                            radius: 7,
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
      ),
    );

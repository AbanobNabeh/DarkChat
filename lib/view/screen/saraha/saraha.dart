import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/states.dart';
import 'package:darkchat/view/screen/saraha/sarahadetails.dart';
import 'package:darkchat/view/screen/saraha/snedsaraha.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';

import '../../../model/sarahahmodel.dart';

class SarahaScreen extends StatelessWidget {
  String phonenumber;
  SarahaScreen(this.phonenumber);
  var scaffoldstate = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitSaraha()
        ..getUser(phonenumber: phonenumber)
        ..getsaraha(phonenumber: phonenumber),
      child: Builder(builder: (context) {
        CubitSaraha.get(context).getsaraha(phonenumber: phonenumber);
        return BlocConsumer<CubitSaraha, StatesSaraha>(
          builder: (context, state) {
            return ConditionalBuilder(
              condition:
                  state is GetUserSarahaLoading || state is GetSarahaLoading,
              builder: (context) => Center(
                child: defCircular(),
              ),
              fallback: (context) => Scaffold(
                key: scaffoldstate,
                appBar: AppBar(
                  title: Text(trans.sarahah),
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => saraha(
                          CubitSaraha.get(context).saraha[index],
                          context,
                          scaffoldstate),
                      separatorBuilder: (context, index) => SizedBox(
                            height: 10,
                          ),
                      itemCount: CubitSaraha.get(context).saraha.length),
                ),
                floatingActionButton:
                    CubitSaraha.get(context).userModel!.sarahah == false
                        ? null
                        : FloatingActionButton(
                            onPressed: () {
                              navto(
                                  context: context,
                                  screen: SendSarahaScreen(phonenumber));
                            },
                            child: Icon(NIcons.plus),
                            backgroundColor: defcolor,
                          ),
              ),
            );
          },
          listener: (context, state) {},
        );
      }),
    );
  }
}

Widget saraha(SarahahModel sarah, BuildContext context, var scaffoldstate) =>
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isdark(trueco: HexColor("F0F0F0"), falseco: HexColor("474747")),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isdark(falseco: HexColor('1A1A1A'), trueco: Colors.grey),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            deftext(
                text: CubitSaraha.get(context)
                    .convertToAgo(DateTime.parse(sarah.datetime!), context),
                size: 12),
            SizedBox(
              height: 3,
            ),
            ReadMoreText(
              sarah.message!,
              style: TextStyle(
                color: isdark(
                    trueco: HexColor('404040'), falseco: HexColor('D1CDCD')),
              ),
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: AppLocalizations.of(context)!.readmore,
              trimExpandedText: AppLocalizations.of(context)!.showless,
              moreStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            sarah.image == null
                ? SizedBox()
                : InkWell(
                    onTap: () {
                      scaffoldstate.currentState!.showBottomSheet((context) {
                        return PhotoViewGallery(
                          pageOptions: [
                            PhotoViewGalleryPageOptions(
                              imageProvider: NetworkImage(sarah.image!),
                            )
                          ],
                        );
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(sarah.image!),
                              fit: BoxFit.cover)),
                    )),
            defDiv(),
            sarah.comment == null
                ? deftext(
                    text: AppLocalizations.of(context)!.noresponse,
                    size: 12,
                    fontWeight: FontWeight.normal)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      deftext(
                          text: AppLocalizations.of(context)!.answered,
                          size: 12),
                      ReadMoreText(
                        sarah.comment!.comment!,
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      sarah.comment!.image != null
                          ? InkWell(
                              onTap: () {
                                scaffoldstate.currentState!
                                    .showBottomSheet((context) {
                                  return PhotoViewGallery(
                                    pageOptions: [
                                      PhotoViewGalleryPageOptions(
                                        imageProvider:
                                            NetworkImage(sarah.comment!.image!),
                                      )
                                    ],
                                  );
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(sarah.comment!.image!),
                                        fit: BoxFit.cover)),
                              ))
                          : SizedBox(
                              width: 0,
                            ),
                      deftext(
                          text: CubitSaraha.get(context).convertToAgo(
                              DateTime.parse(sarah.comment!.datetime!),
                              context),
                          size: 12),
                    ],
                  )
          ],
        ),
      ),
    );

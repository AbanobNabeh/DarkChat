import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitsaraha/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/message_icons.dart';

class SarahaDetailsScreen extends StatelessWidget {
  String idsaraha;
  SarahaDetailsScreen(this.idsaraha);
  TextEditingController comment = TextEditingController();
  var scaffoldstate = GlobalKey<ScaffoldState>();
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitSaraha()..getsarahadetails(idsaraha),
      child: BlocConsumer<CubitSaraha, StatesSaraha>(
        builder: (context, state) => Scaffold(
          key: scaffoldstate,
          appBar: AppBar(),
          body: state is GetSarahaDetLoading
              ? Center(child: defCircular())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Form(
                      key: formstate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          deftext(
                              text: CubitSaraha.get(context).convertToAgo(
                                  DateTime.parse(CubitSaraha.get(context)
                                      .sarahadet['datetime']),
                                  context),
                              size: 12),
                          SizedBox(
                            height: 10,
                          ),
                          ReadMoreText(
                            CubitSaraha.get(context).sarahadet['message'],
                            style: TextStyle(
                              color: isdark(
                                  trueco: HexColor('404040'),
                                  falseco: HexColor('D1CDCD')),
                            ),
                            trimLines: 4,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: trans.readmore,
                            trimExpandedText: trans.showless,
                            moreStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          CubitSaraha.get(context).sarahadet['image'] == null
                              ? SizedBox(
                                  width: 0,
                                )
                              : InkWell(
                                  onTap: () {
                                    scaffoldstate.currentState!
                                        .showBottomSheet((context) {
                                      return PhotoViewGallery(
                                        pageOptions: [
                                          PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(
                                                CubitSaraha.get(context)
                                                    .sarahadet['image']),
                                          )
                                        ],
                                      );
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            CubitSaraha.get(context)
                                                .sarahadet['image'],
                                          ),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                          SizedBox(
                            height: 15,
                          ),
                          defDiv(),
                          SizedBox(
                            height: 15,
                          ),
                          CubitSaraha.get(context).sarahadet['comment'] == null
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isdark(
                                        falseco: HexColor('474747'),
                                        trueco: HexColor('E3E3E3')),
                                  ),
                                  child: TextFormField(
                                    controller: comment,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "";
                                      }
                                    },
                                    onChanged: (value) {},
                                    decoration: InputDecoration(
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      errorStyle: TextStyle(fontSize: 0),
                                      hintText: trans.addreply,
                                      hintStyle: TextStyle(
                                          color: isdark(
                                              trueco: HexColor('B4B3B3'),
                                              falseco: HexColor('959595'))),
                                      border: InputBorder.none,
                                      prefixIcon: IconButton(
                                          onPressed: () {
                                            CubitSaraha.get(context)
                                                        .imagecomment ==
                                                    null
                                                ? CubitSaraha.get(context)
                                                    .gallerypermission()
                                                : CubitSaraha.get(context)
                                                    .removeimage();
                                          },
                                          icon: CubitSaraha.get(context)
                                                      .imagecomment ==
                                                  null
                                              ? Icon(NIcons.picture,
                                                  color: defcolor)
                                              : Icon(NIcons.trash,
                                                  color: defcolor)),
                                      suffixIcon: state is AddCommentLoading ||
                                              state is UploadImageComment
                                          ? defCircular()
                                          : IconButton(
                                              icon: Icon(
                                                Icons.send,
                                                color: defcolor,
                                              ),
                                              onPressed: () {
                                                if (formstate.currentState!
                                                    .validate()) {
                                                  if (CubitSaraha.get(context)
                                                          .imagecomment ==
                                                      null) {
                                                    CubitSaraha.get(context)
                                                        .addcomment(
                                                            comment:
                                                                comment.text,
                                                            idsaraha: idsaraha);
                                                  } else {
                                                    CubitSaraha.get(context)
                                                        .uploadimagecoment(
                                                            comment:
                                                                comment.text,
                                                            idsaraha: idsaraha);
                                                  }
                                                }
                                              },
                                            ),
                                    ),
                                    cursorColor: defcolor,
                                  ),
                                )
                              : InkWell(
                                  onLongPress: () {
                                    AlertDialog alert = AlertDialog(
                                      title: Text(
                                        trans.delete,
                                        style: TextStyle(color: defcolor),
                                      ),
                                      content: Text(trans.deleterep),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context, 'Sign Out'),
                                          child: Text(trans.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            CubitSaraha.get(context)
                                                .deletecomment(
                                                    idsaraha, context);
                                          },
                                          child: Text(trans.ok),
                                        ),
                                      ],
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ReadMoreText(
                                        CubitSaraha.get(context)
                                            .sarahadet['comment']['comment'],
                                        style: TextStyle(
                                          color: isdark(
                                              trueco: HexColor('404040'),
                                              falseco: HexColor('D1CDCD')),
                                        ),
                                        trimLines: 4,
                                        trimMode: TrimMode.Line,
                                        trimCollapsedText: trans.readmore,
                                        trimExpandedText: trans.showless,
                                        moreStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
                                      ),
                                      CubitSaraha.get(context)
                                                      .sarahadet['comment']
                                                  ['image'] !=
                                              null
                                          ? InkWell(
                                              onTap: () {
                                                scaffoldstate.currentState!
                                                    .showBottomSheet((context) {
                                                  return PhotoViewGallery(
                                                    pageOptions: [
                                                      PhotoViewGalleryPageOptions(
                                                        imageProvider: NetworkImage(
                                                            CubitSaraha.get(
                                                                        context)
                                                                    .sarahadet[
                                                                'comment']['image']),
                                                      )
                                                    ],
                                                  );
                                                });
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        CubitSaraha.get(context)
                                                                .sarahadet[
                                                            'comment']['image'],
                                                      ),
                                                      fit: BoxFit.fill),
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              width: 0,
                                            ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      deftext(
                                          text: CubitSaraha.get(context)
                                              .convertToAgo(
                                                  DateTime.parse(CubitSaraha
                                                              .get(context)
                                                          .sarahadet['comment']
                                                      ['datetime']),
                                                  context),
                                          size: 12),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        listener: (context, state) {
          if (state is GetSarahaDetSuccess) {
            CubitSaraha.get(context).readsaraha(idsaraha);
          }
        },
      ),
    );
  }
}

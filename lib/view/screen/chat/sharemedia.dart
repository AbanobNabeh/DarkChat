import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:darkchat/view/screen/chat/PDFview.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ShareMediaScreen extends StatelessWidget {
  String phonenumber;
  ShareMediaScreen(this.phonenumber);
  var scaffoldstate = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitChat()..getimage(phonenumber),
      child: BlocConsumer<CubitChat, StatesChat>(
        builder: (context, state) {
          return Scaffold(
            key: scaffoldstate,
            appBar: AppBar(
              title: Text(phonenumber),
            ),
            body: DefaultTabController(
              length: 2,
              child: ConditionalBuilder(
                condition: state is GetShareMediaLoading,
                builder: (context) => Center(child: defCircular()),
                fallback: (context) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15),
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
                                text: trans.pictures,
                                size: 15,
                              ),
                              deftext(
                                text: trans.documents,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: CubitChat.get(context).sharemedie.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                scaffoldstate.currentState!
                                    .showBottomSheet((context) {
                                  return PhotoViewGallery.builder(
                                    pageController:
                                        PageController(initialPage: index),
                                    itemCount: CubitChat.get(context)
                                        .sharemedie
                                        .length,
                                    builder: ((context, index) {
                                      return PhotoViewGalleryPageOptions(
                                          imageProvider: NetworkImage(
                                              CubitChat.get(context)
                                                      .sharemedie[index]
                                                  ['messageimage']),
                                          minScale:
                                              PhotoViewComputedScale.contained,
                                          maxScale:
                                              PhotoViewComputedScale.contained *
                                                  5);
                                    }),
                                  );
                                });
                              },
                              child: Image(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(CubitChat.get(context)
                                      .sharemedie[index]['messageimage'])),
                            );
                          },
                        ),
                        ListView.separated(
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  navto(
                                      context: context,
                                      screen: PDFviewScreen(
                                          CubitChat.get(context)
                                              .sharemediedocument[index]));
                                },
                                child: ListTile(
                                  title: deftext(
                                      text: CubitChat.get(context)
                                          .sharemediedocument[index]
                                          .name!,
                                      size: 16),
                                  subtitle: deftext(
                                      text: CubitChat.get(context)
                                          .formatSizefile(
                                              CubitChat.get(context)
                                                  .sharemediedocument[index]
                                                  .bytes!,
                                              context),
                                      size: 14),
                                  leading: Icon(
                                    NIcons.file_pdf,
                                    color: defcolor,
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => defDiv(),
                            itemCount: CubitChat.get(context)
                                .sharemediedocument
                                .length)
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}

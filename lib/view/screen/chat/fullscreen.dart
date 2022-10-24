import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:darkchat/model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../constants/constants.dart';
import '../../../cubit/cubitchat/cubit.dart';

class FullScreen extends StatelessWidget {
  var phonenumber;
  var image;
  FullScreen(this.image, this.phonenumber);
  TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitChat()..getuser(phonenumber: phonenumber),
      child: BlocConsumer<CubitChat, StatesChat>(
        builder: (context, state) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            child: Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image(
                      image: FileImage(image),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: isdark(
                            trueco: HexColor("E3E3E3"),
                            falseco: HexColor("474747"),
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextFormField(
                        controller: message,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "";
                          }
                        },
                        decoration: InputDecoration(
                          hintText: trans.writemessage,
                          hintStyle: TextStyle(
                              color: isdark(
                                  trueco: HexColor('B4B3B3'),
                                  falseco: HexColor('959595'))),
                          border: InputBorder.none,
                          suffixIcon: state is UploadImageLoading
                              ? defCircular()
                              : IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: defcolor,
                                  ),
                                  onPressed: () {
                                    CubitChat.get(context).uploadimagechat(
                                      image: image,
                                      message: message.text,
                                      phonenumber: phonenumber,
                                      name: CubitChat.get(context)
                                          .userchat['name'],
                                      imageuser: CubitChat.get(context)
                                          .userchat['image'],
                                      context: context,
                                    );
                                  },
                                ),
                        ),
                        cursorColor: defcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        listener: (context, state) {},
      ),
    );
  }
}

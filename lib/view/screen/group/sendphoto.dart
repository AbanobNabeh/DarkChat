import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
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
  var idgroup;
  var image;
  FullScreen(this.image, this.idgroup);
  TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup()..getGroupinfo(idgroup),
      child: BlocConsumer<CubitGroup, StatesGroup>(
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
                          suffixIcon: state is SendImageLoading
                              ? defCircular()
                              : IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: defcolor,
                                  ),
                                  onPressed: () {
                                    CubitGroup.get(context).sendimage(
                                        idgroup: idgroup,
                                        message: message.text,
                                        context: context,
                                        image: image);
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
        listener: (context, state) {
          if (state is SendMessageSuccess) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

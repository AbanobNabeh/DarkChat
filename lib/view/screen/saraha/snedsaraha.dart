import 'package:darkchat/cubit/cubitsaraha/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/states.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../constants/constants.dart';

class SendSarahaScreen extends StatelessWidget {
  String phonenumber;
  SendSarahaScreen(this.phonenumber);
  var message = TextEditingController();

  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitSaraha()..getUser(phonenumber: phonenumber),
      child: BlocConsumer<CubitSaraha, StatesSaraha>(
          builder: (context, state) {
            var cubit = CubitSaraha.get(context);
            return Scaffold(
              appBar: state is GetUserSarahaLoading
                  ? null
                  : AppBar(
                      title: Text(CubitSaraha.get(context).userModel!.name!),
                    ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: formstate,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isdark(
                                  falseco: HexColor('474747'),
                                  trueco: HexColor('E3E3E3')),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                  maxLines: null,
                                  maxLength: 350,
                                  controller: message,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return trans.send;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    focusedErrorBorder: InputBorder.none,
                                    errorStyle: TextStyle(fontSize: 0),
                                    hintText: trans.writemessage,
                                    hintStyle: TextStyle(
                                        color: isdark(
                                            trueco: HexColor('B4B3B3'),
                                            falseco: HexColor('959595'))),
                                    border: InputBorder.none,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                cubit.image != null
                                    ? cubit.removeimage()
                                    : cubit.requestPermission();
                              },
                              child: cubit.image != null
                                  ? Text(Uri.file(cubit.image!.path)
                                      .pathSegments
                                      .last)
                                  : Text(trans.selectimage)),
                          state is UploadImageLoading ||
                                  state is SendSarahaLoading
                              ? Center(child: defCircular())
                              : defbutton(
                                  text: trans.send,
                                  ontap: () {
                                    if (formstate.currentState!.validate()) {
                                      if (cubit.image == null) {
                                        cubit.sendsaraha(
                                            context: context,
                                            message: message.text,
                                            phonenumber: phonenumber,
                                            token: CubitSaraha.get(context)
                                                .userModel!
                                                .token!);
                                        message.text = "";
                                      } else {
                                        cubit.uploadsarahimage(
                                            phonenumber: phonenumber,
                                            message: message.text,
                                            context: context,
                                            token: CubitSaraha.get(context)
                                                .userModel!
                                                .token!);
                                        message.text = "";
                                        cubit.image = null;
                                      }
                                    }
                                  })
                        ]),
                  ),
                ),
              ),
            );
          },
          listener: (context, state) {}),
    );
  }
}

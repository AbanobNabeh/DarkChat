import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/cubit/cubitauth/states.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';

class CompletingAccountScreen extends StatelessWidget {
  var phonenumber;
  CompletingAccountScreen(this.phonenumber);
  TextEditingController name = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController birthday = TextEditingController();
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitAuth, StatesAuth>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: ConditionalBuilder(
          builder: (context) => Center(child: defCircular()),
          condition: state is UploadProfileLoading,
          fallback: (context) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Form(
                key: formstate,
                child: Column(
                  children: [
                    deftext(
                        text: trans.detailssignup,
                        size: 15,
                        color: HexColor('F4A135'),
                        fontWeight: FontWeight.normal),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        CubitAuth.get(context).requestPermissionpost();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isdark(
                                  trueco: Colors.black26, falseco: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              image: CubitAuth.get(context).image != null
                                  ? DecorationImage(
                                      image: FileImage(
                                          CubitAuth.get(context).image!),
                                      fit: BoxFit.fill)
                                  : null,
                            ),
                          ),
                          CubitAuth.get(context).image == null
                              ? Icon(NIcons.camera)
                              : SizedBox()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    defFormFiled(
                        text: trans.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return trans.name;
                          } else {
                            return null;
                          }
                        },
                        controller: name,
                        iconData: NIcons.user,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.name),
                    SizedBox(
                      height: 15,
                    ),
                    defFormFiled(
                        text: trans.bio,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return trans.bio;
                          } else {
                            return null;
                          }
                        },
                        controller: bio,
                        iconData: NIcons.info,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.text),
                    SizedBox(
                      height: 15,
                    ),
                    defFormFiled(
                        text: trans.email,
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                  .hasMatch(value)) {
                            return trans.email;
                          } else {
                            return null;
                          }
                        },
                        controller: email,
                        iconData: NIcons.mail,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress),
                    SizedBox(
                      height: 15,
                    ),
                    defFormFiled(
                        text: trans.date,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return trans.date;
                          } else {
                            return null;
                          }
                        },
                        controller: birthday,
                        iconData: NIcons.calendar,
                        textInputAction: TextInputAction.send,
                        textInputType: TextInputType.none,
                        ontap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1800),
                                  lastDate: DateTime.now())
                              .then((value) {
                            birthday.text = DateFormat.yMMMMd().format(value!);
                          });
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    defbutton(
                        text: trans.submit,
                        ontap: () {
                          if (CubitAuth.get(context).image == null) {
                            Fluttertoast.showToast(msg: trans.selectimage);
                          } else {
                            if (formstate.currentState!.validate()) {
                              CubitAuth.get(context).uploadimage(
                                  name: name.text,
                                  email: email.text,
                                  barthday: birthday.text,
                                  bio: bio.text,
                                  phonenumber: phonenumber,
                                  context: context);
                            }
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      listener: (context, state) {},
    );
  }
}

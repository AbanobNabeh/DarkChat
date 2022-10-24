import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/constants.dart';
import '../widget/message_icons.dart';

class EditProfileScreen extends StatelessWidget {
  var name = TextEditingController();
  var bio = TextEditingController();
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitHome, StatesHome>(
      builder: (context, state) {
        name.text = CubitHome.get(context).modelProfile!.name!;
        bio.text = CubitHome.get(context).modelProfile!.bio!;
        return Scaffold(
          appBar: AppBar(
            title: Text(trans.editprofile),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: formstate,
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        CircleAvatar(
                            radius: 75,
                            backgroundImage:
                                CubitHome.get(context).imageload()),
                        InkWell(
                          onTap: () {
                            CubitHome.get(context).requestPermissiongallery();
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: isdark(
                                trueco: HexColor('FAFAFA'),
                                falseco: HexColor('404040')),
                            child: Icon(
                              NIcons.camera,
                              size: 20,
                              color: defcolor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 55,
                    ),
                    defFormFiled(
                      text: trans.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return trans.name;
                        }
                      },
                      controller: name,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    defFormFiled(
                      text: trans.bio,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return trans.bio;
                        }
                      },
                      controller: bio,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    state is EditProfileImageLoading ||
                            state is EditProfileLoading
                        ? defCircular()
                        : defbutton(
                            text: trans.edit,
                            ontap: () {
                              if (formstate.currentState!.validate()) {
                                if (CubitHome.get(context).image == null) {
                                  CubitHome.get(context).editprofile(
                                      name: name.text, bio: bio.text);
                                } else {
                                  CubitHome.get(context).editimage(
                                      name: name.text, bio: bio.text);
                                }
                              }
                            })
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}

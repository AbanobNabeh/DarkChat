import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNewGroupScreen extends StatelessWidget {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup(),
      child: BlocConsumer<CubitGroup, StatesGroup>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(trans.createnewgroup),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formstate,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          CubitGroup.get(context)
                              .requestPermission(context: context);
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: defcolor,
                          child: CubitGroup.get(context).image == null
                              ? deftext(text: trans.selectimage, size: 12)
                              : CircleAvatar(
                                  radius: 55,
                                  backgroundImage:
                                      FileImage(CubitGroup.get(context).image!),
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      defFormFiled(
                          text: trans.groupname,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return trans.groupname;
                            }
                          },
                          controller: name,
                          iconData: Icons.text_fields,
                          maxlenght: 30,
                          textInputType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          maxtext: ""),
                      SizedBox(
                        height: 25,
                      ),
                      defFormFiled(
                        text: trans.groupdescription,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return trans.groupdescription;
                          }
                        },
                        textInputType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        controller: description,
                        iconData: Icons.info,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      state is CreateGroupLoading || state is UploadImageLoading
                          ? Center(child: defCircular())
                          : defbutton(
                              text: trans.next,
                              ontap: () {
                                if (formstate.currentState!.validate()) {
                                  if (CubitGroup.get(context).image == null) {
                                    CubitGroup.get(context).creategroup(
                                        name: name.text,
                                        description: description.text,
                                        context: context);
                                  } else {
                                    CubitGroup.get(context).uploadimagegroup(
                                        name: name.text,
                                        description: description.text,
                                        context: context);
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
      ),
    );
  }
}

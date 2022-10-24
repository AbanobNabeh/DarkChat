import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../constants/constants.dart';

class EditGroupScreen extends StatelessWidget {
  String idgroup;
  EditGroupScreen(this.idgroup);
  var name = TextEditingController();
  var description = TextEditingController();
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup()..getGroupinfo(idgroup),
      child: BlocConsumer<CubitGroup, StatesGroup>(
        builder: (context, state) {
          if (state is! GetGroupLoading) {
            name.text = CubitGroup.get(context).group['name'];
            description.text = CubitGroup.get(context).group['description'];
          }
          return Scaffold(
            appBar: AppBar(),
            body: state is GetGroupLoading
                ? Center(child: defCircular())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Form(
                        key: formstate,
                        child: Column(
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                CircleAvatar(
                                    radius: 75,
                                    backgroundImage:
                                        CubitGroup.get(context).imageload()),
                                InkWell(
                                  onTap: () {
                                    CubitGroup.get(context).requseteditimage();
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
                              text: "",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return trans.groupname;
                                }
                              },
                              controller: name,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            defFormFiled(
                              text: "",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return trans.groupdescription;
                                }
                              },
                              controller: description,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            state is EditGroupLoading ||
                                    state is EditGroupimageLoading
                                ? defCircular()
                                : defbutton(
                                    text: trans.submit,
                                    ontap: () {
                                      if (CubitGroup.get(context).editimage ==
                                          null) {
                                        if (formstate.currentState!
                                            .validate()) {
                                          CubitGroup.get(context).editGroup(
                                              idgroup: idgroup,
                                              name: name.text,
                                              description: description.text);
                                        }
                                      } else {
                                        CubitGroup.get(context).editgroupimage(
                                            idgroup: idgroup,
                                            name: name.text,
                                            description: description.text);
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

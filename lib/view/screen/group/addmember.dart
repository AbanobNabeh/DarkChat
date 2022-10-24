import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/constants.dart';

class AddMemberScreen extends StatelessWidget {
  String idgroup;
  AddMemberScreen(this.idgroup);
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CubitGroup()..getusers(idgroup),
      child: BlocConsumer<CubitGroup, StatesGroup>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(trans.addmembers),
            ),
            body: state is GetUsersLoading
                ? Center(child: defCircular())
                : ListView.separated(
                    itemBuilder: (context, index) => members(
                        CubitGroup.get(context).newMember[index],
                        context,
                        index),
                    separatorBuilder: (context, index) => defDiv(),
                    itemCount: CubitGroup.get(context).newMember.length),
            floatingActionButton: state is AddNewMemberLoading
                ? defCircular()
                : FloatingActionButton(
                    onPressed: () {
                      CubitGroup.get(context).addnewmember(idgroup, context);
                      CubitGroup.get(context).sendnotification(
                          context, CubitGroup.get(context).newMember, "select");
                    },
                    child: Icon(Icons.navigate_next),
                    backgroundColor: defcolor,
                  ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}

Widget members(user, context, index) => InkWell(
      onTap: user['select'] == "old"
          ? null
          : () {
              CubitGroup.get(context).selectnewmemeber(index);
            },
      child: Container(
        width: double.infinity,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(user['image']))),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                deftext(text: user['name'], size: 16),
                deftext(
                    text: user['phonenumber'],
                    size: 14,
                    fontWeight: FontWeight.normal)
              ],
            ),
          ),
          user['select'] == "old"
              ? Icon(
                  Icons.check_circle,
                  color: Colors.grey,
                )
              : user['select'] == "new"
                  ? Icon(Icons.check_circle_outline)
                  : Icon(
                      Icons.check_circle,
                      color: defcolor,
                    )
        ]),
      ),
    );

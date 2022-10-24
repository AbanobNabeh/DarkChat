import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../cubit/cubitgroup/cubit.dart';
import '../../../cubit/cubitgroup/states.dart';

class AddUsersScreen extends StatelessWidget {
  String id;
  AddUsersScreen(this.id);
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
        create: (context) => CubitGroup()..getUsers(),
        child: BlocConsumer<CubitGroup, StatesGroup>(
          builder: (context, state) {
            return ConditionalBuilder(
                condition: state is SelectUserLoading,
                builder: (context) => Center(
                      child: defCircular(),
                    ),
                fallback: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(trans.addmembers),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                  itemBuilder: (context, index) => users(
                                      CubitGroup.get(context).users[index],
                                      context,
                                      index),
                                  separatorBuilder: (context, index) =>
                                      defDiv(),
                                  itemCount:
                                      CubitGroup.get(context).users.length),
                            ),
                            state is AddMemberLoading
                                ? defCircular()
                                : defbutton(
                                    text: trans.next,
                                    ontap: () {
                                      CubitGroup.get(context)
                                          .addmember(id, context);
                                      CubitGroup.get(context).sendnotification(
                                          context,
                                          CubitGroup.get(context).users,
                                          true);
                                    })
                          ],
                        ),
                      ),
                    ));
          },
          listener: (context, state) {},
        ));
  }
}

Widget users(user, context, index) => InkWell(
      onTap: () {
        CubitGroup.get(context).selectuser(index);
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
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                      image: NetworkImage(user['image']), fit: BoxFit.fill)),
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
          user['select'] == false
              ? Icon(Icons.check_circle_outline)
              : Icon(
                  Icons.check_circle,
                  color: defcolor,
                )
        ]),
      ),
    );

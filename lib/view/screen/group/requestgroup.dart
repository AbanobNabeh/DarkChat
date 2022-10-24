import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitgroup/cubit.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocProvider(
        create: (context) => CubitGroup()..getGroups(),
        child: BlocConsumer<CubitGroup, StatesGroup>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(trans.requests),
              ),
              body: ListView.separated(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          CubitGroup.get(context)
                                              .requests[index]
                                              .image!),
                                      fit: BoxFit.cover)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                deftext(
                                    text: CubitGroup.get(context)
                                        .requests[index]
                                        .name!,
                                    size: 16,
                                    maxlines: 1,
                                    overflow: TextOverflow.ellipsis),
                                deftext(
                                    text: CubitGroup.get(context)
                                        .requests[index]
                                        .createdby!,
                                    size: 14)
                              ],
                            )),
                            IconButton(
                                onPressed: () {
                                  CubitGroup.get(context).acceptrequest(
                                      CubitGroup.get(context)
                                          .requests[index]
                                          .id!,
                                      CubitGroup.get(context)
                                          .requests[index]
                                          .topic!);
                                },
                                icon: Icon(
                                  Icons.check_box,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () {
                                  CubitGroup.get(context).declinedrequest(
                                      CubitGroup.get(context)
                                          .requests[index]
                                          .id!);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => defDiv(),
                  itemCount: CubitGroup.get(context).requests.length),
            );
          },
          listener: (context, state) {},
        ));
  }
}

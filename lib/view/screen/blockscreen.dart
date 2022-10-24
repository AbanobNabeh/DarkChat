import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget/message_icons.dart';

class BlockScreen extends StatelessWidget {
  const BlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitHome()..getblock(),
      child: BlocConsumer<CubitHome, StatesHome>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.blocked),
            ),
            body: state is GetBlockerLoading
                ? Center(
                    child: defCircular(),
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            navto(
                                context: context,
                                screen: ProfileUserScreen(CubitHome.get(context)
                                    .blocked[index]['phonenumber']));
                          },
                          child: Container(
                            child: Row(children: [
                              Container(
                                width: 50,
                                height: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            CubitHome.get(context)
                                                .blocked[index]['image']),
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
                                        text: CubitHome.get(context)
                                            .blocked[index]['name'],
                                        size: 16),
                                    deftext(
                                        text: CubitHome.get(context)
                                            .blocked[index]['phonenumber'],
                                        size: 16),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => defDiv(),
                    itemCount: CubitHome.get(context).blocked.length),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}

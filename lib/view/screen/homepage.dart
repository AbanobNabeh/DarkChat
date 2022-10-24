import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/network/cachhelper.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/model/modelprofile.dart';
import 'package:darkchat/view/screen/searchscreen.dart';
import 'package:darkchat/view/screen/settingscreen.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitHome, StatesHome>(
      builder: (context, state) => ConditionalBuilder(
        condition: state is GetProfileLoading,
        builder: (context) => Center(child: defCircular()),
        fallback: (context) => Scaffold(
          appBar: AppBar(
            title: Text(CubitHome.get(context).modelProfile!.name!),
            leading: IconButton(
              onPressed: () {
                navto(context: context, screen: SearchScreen());
              },
              icon: Icon(NIcons.search),
            ),
            actions: [
              InkWell(
                onTap: () {
                  navto(context: context, screen: SettingScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: NetworkImage(
                                CubitHome.get(context).modelProfile!.image!),
                            fit: BoxFit.cover)),
                  ),
                ),
              )
            ],
          ),
          extendBody: true,
          bottomNavigationBar: FloatingNavbar(
            onTap: (int index) {
              CubitHome.get(context).ChangeBottomScreen(index);
            },
            currentIndex: CubitHome.get(context).curentindx,
            backgroundColor:
                isdark(trueco: HexColor("FFFFFF"), falseco: HexColor("1A1A1A")),
            unselectedItemColor: HexColor('8C8C8C'),
            selectedItemColor: HexColor('F4A135'),
            selectedBackgroundColor:
                isdark(trueco: HexColor("1A1A1A"), falseco: HexColor("FFFFFF")),
            borderRadius: 10,
            elevation: 20,
            items: CubitHome.get(context).items,
          ),
          body:
              CubitHome.get(context).screen[CubitHome.get(context).curentindx],
        ),
      ),
      listener: (context, state) {},
    );
  }
}

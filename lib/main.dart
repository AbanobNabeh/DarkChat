import 'dart:io';

import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/constants/theme/theme.dart';
import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/view/screen/Splash.dart';
import 'package:darkchat/view/screen/chat/chatscreen.dart';
import 'package:darkchat/view/screen/group/groupscreen.dart';
import 'package:darkchat/view/screen/group/requestgroup.dart';
import 'package:darkchat/view/screen/homepage.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:darkchat/view/screen/saraha/sarahadetails.dart';
import 'package:darkchat/view/screen/settingscreen.dart';
import 'package:darkchat/view/widget/lifecyclemanager/lifecyclemanager.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'constants/network/cachhelper.dart';
import 'cubit/blocobserver.dart';
import 'cubit/cubithome/states.dart';
import 'cubit/cubitsaraha/cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  AwesomeNotifications().initialize(null, [
    NotificationChannel(

      channelKey: "basic_channel_key",
      channelName: "Basic Channel",
      channelDescription: "Used to send the main notifications to our users",
      channelShowBadge: true,
      defaultColor: defcolor,
      enableLights: true,
      enableVibration: true,
      importance: NotificationImportance.Max,
      playSound: true,
    )
  ]);
  FirebaseMessaging.instance.getToken().then((val) {
    print(val);
  });

  BlocOverrides.runZoned(
    () {
      runApp(MyApp());
    },
    blocObserver: MyBlocObserver(),
  );
  FIREUSER.doc(id).update({"state": "online"});
}

class MyApp extends StatelessWidget {
  String lange = lang == null ? Platform.localeName : lang;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    Future<void> _firebaseMessagingBackgroundHandler(
        RemoteMessage message) async {
      await Firebase.initializeApp();
print("AAAAAAAAAAAAA");

    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: ((receivedAction) async {
      if (receivedAction.id == 1) {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: ChatScreen(
                phonenumber: receivedAction.payload!['phonenumber']!));
      } else if (receivedAction.id == 2) {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: RequestGroupScreen());
      } else if (receivedAction.id == 3) {
        CubitHome.get(
          navigatorKey.currentState!.overlay!.context,
        ).curentindx = 1;
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: HomePage());
        FirebaseMessaging.instance
            .unsubscribeFromTopic(receivedAction.payload!['topic']!);
      } else if (receivedAction.id == 4) {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: GroupScreen(receivedAction.payload!['idgroup']!));
      } else if (receivedAction.id == 5) {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: SarahaDetailsScreen(receivedAction.payload!['idsaraha']!));
      } else if (receivedAction.id == 6) {
        CubitHome.get(
          navigatorKey.currentState!.overlay!.context,
        ).curentindx = 3;
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: HomePage());
      }
    }));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      message.data['id'] == "3"
          ? FirebaseMessaging.instance
              .unsubscribeFromTopic(message.data['topic']!)
          : null;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
        largeIcon: message.data['icon'] != null ? message.data['icon'] : null,
        bigPicture: message.notification!.android!.imageUrl != null
            ? message.notification!.android!.imageUrl!
            : null,
        id: int.parse(message.data['id']),
        channelKey: 'basic_channel_key',
        title: message.notification!.title,
        body: message.notification!.body,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          "idsaraha": "${message.data['idsaraha']}",
          "idgroup": "${message.data['idgroup']}",
          "phonenumber": "${message.data['phonenumber']}",
          "topic": "${message.data['topic']}",
        },
      ));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['id'] == "1") {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: ChatScreen(
              phonenumber: message.data['phonenumber'],
            ));
      } else if (message.data['id'] == "2") {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: RequestGroupScreen());
      } else if (message.data['id'] == "3") {
        CubitHome.get(navigatorKey.currentState!.overlay!.context).curentindx =
            1;
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: HomePage());
      } else if (message.data['id'] == "4") {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: GroupScreen(message.data['idgroup']!));
      } else if (message.data['id'] == "5") {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: SarahaDetailsScreen(message.data['idsaraha']!));
      } else if (message.data['id'] == "6") {
        navto(
            context: navigatorKey.currentState!.overlay!.context,
            screen: SarahaDetailsScreen(message.data['idsaraha']!));
      }
    });
    return LifeCycleManager(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CubitAuth()),
          BlocProvider(
              create: (context) => CubitHome()
                ..getProfile(phonenumber: id.toString())
                ..getMyFav()
                ..getHisFav()),
        ],
        child: BlocConsumer<CubitHome, StatesHome>(
          builder: (context, state) => MaterialApp(
            themeMode: theme == true ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(lange == "en_US" ? "en" : "ar"),
            debugShowCheckedModeBanner: false,
            theme: lightthem(),
            darkTheme: darktheme(),
            home: SplashScreen(),
            navigatorKey: navigatorKey,
          ),
          listener: (context, state) {},
        ),
      ),
    );
  }
}

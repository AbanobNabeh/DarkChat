import 'dart:io';
import 'dart:math';

import 'package:darkchat/view/screen/auth/phonenumber.dart';
import 'package:darkchat/view/screen/fav/favscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/constants/network/cachhelper.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/main.dart';
import 'package:darkchat/model/modelprofile.dart';
import 'package:darkchat/model/usermodel.dart';
import 'package:darkchat/view/screen/chat/chatlistscreen.dart';
import 'package:darkchat/view/screen/group/grouplistscreen.dart';
import 'package:darkchat/view/screen/saraha/sarahalist.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/network/apinotification.dart';
import '../../view/widget/message_icons.dart';

class CubitHome extends Cubit<StatesHome> {
  CubitHome() : super(initAuthState());
  static CubitHome get(context) => BlocProvider.of(context);
  int curentindx = 0;

  ChangeBottomScreen(index) {
    curentindx = index;

    emit(ChangebottomScreen());
  }

  List<FloatingNavbarItem>? items = [
    FloatingNavbarItem(
      icon: NIcons.comment,
    ),
    FloatingNavbarItem(icon: NIcons.chat),
    FloatingNavbarItem(icon: Icons.contact_support),
    FloatingNavbarItem(
      icon: NIcons.heart,
    ),
  ];

  List screen = [
    ChatListScreen(),
    GroupListScreen(),
    SarahListScreen(),
    FAVSacreen()
  ];

  List search = [];
  searchuser({required String phonenumber}) {
    emit(SearchLoading());
    FIREUSER
        .where("searchcase", arrayContains: phonenumber)
        .get()
        .then((value) {
      search = [];
      value.docs.forEach((element) {
        if (element.id == id || element.data()['private'] == true) {
        } else {
          search.add(element.data());
        }
      });
      emit(SearchSeccuss());
    }).catchError((error) {
      emit(SearchError());
    });
  }

  UserModel? userModel;
  getuser({required String phonenumber}) {
    emit(GetUserLoading());
    FIREUSER.doc(phonenumber).get().then((value) {
      userModel = UserModel.fromJson(value.data()!);
      emit(GetUserSuccess());
    });
  }

  addfavoriteperson(
      {required String phonenumber, required BuildContext context}) {
    emit(AddFavPersonLoading());
    print(phonenumber);
    FIREUSER
        .doc(id)
        .collection(HISFAV)
        .where("phonenumber", isEqualTo: phonenumber)
        .get()
        .then((value) {
      print(value.docs.toString());
      if (value.docs.isEmpty) {
        FIREUSER.doc(phonenumber).collection(HISFAV).doc(id).set({
          "phonenumber": id,
          "by": "1",
        }).then((value) {
          FIREUSER.doc(id).collection(MYFAV).doc(phonenumber).set({
            "phonenumber": phonenumber,
            "by": "1",
          }).then((value) {
            sendnotification(by: "50%");
            Navigator.pop(context, 'cancel');
            emit(AddFavPersonSuccess());
          });
        });
      } else {
        updatefav(phonenumber, context);
      }
    });
  }

  updatefav(String phonenumber, context) {
    FIREUSER
        .doc(phonenumber)
        .collection(HISFAV)
        .doc(id)
        .set({"phonenumber": id, "by": "2"}).then((value) {
      FIREUSER
          .doc(phonenumber)
          .collection(MYFAV)
          .doc(id)
          .update({"by": "2"}).then((value) {
        FIREUSER
            .doc(id)
            .collection(HISFAV)
            .doc(phonenumber)
            .update({"by": "2"}).then((value) {
          FIREUSER
              .doc(id)
              .collection(MYFAV)
              .doc(phonenumber)
              .set({"phonenumber": phonenumber, "by": "2"}).then((value) {
            Navigator.pop(context, 'cancel');
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.favnote,
              backgroundColor: Colors.green,
              toastLength: Toast.LENGTH_LONG,
            );

            sendnotification(by: "100%");
            emit(AddFavPersonSuccess());
          });
        });
      });
    });
  }

  sendnotification({
    required String by,
  }) {
    APInotification.postRequset(data: {
      "to": userModel!.token!,
      "notification": {
        "title": "❤",
        "body": by,
        "sounde": "default",
      },
      "data": {
        'id': 6,
        "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
      }
    });
  }

  bool checkLike = false;
  checklike({required String phonenumber}) {
    emit(CheckLikeLoading());
    FIREUSER
        .doc(phonenumber)
        .collection(HISFAV)
        .where("phonenumber", isEqualTo: id)
        .snapshots()
        .listen((value) {
      checkLike = false;
      if (value.docs.isNotEmpty) {
        checkLike = true;
      }

      emit(CheckLikeSuccess());
    });
  }

  changetheme(value, context) {
    theme = value;
    CacheHelper.saveData(key: "theme", value: value).then((value) {
      navof(context: context, screen: MyApp());
    });
    emit(ChangeThemeSuccess());
  }

  ModelProfile? modelProfile;
  getProfile({required String phonenumber}) {
    emit(GetProfileLoading());
    FIREUSER.doc(phonenumber).get().then((value) {
      modelProfile = ModelProfile.fromJson(value.data()!);
      emit(GetProfileSuccess());
    }).catchError((error) {
      emit(GetProfileError());
    });
  }

  onsarahah(value) {
    FIREUSER.doc(id).update({"sarahah": value}).then((value) {
      getProfile(phonenumber: id);
      emit(ChangesarahahSuccess());
    });
  }

  onpriveta(value) {
    FIREUSER.doc(id).update({"private": value}).then((value) {
      getProfile(phonenumber: id);
      emit(ChangePrivateSuccess());
    });
  }

  bool checkblock = false;
  checkBlock(String phonenumber) {
    emit(CheckBlockLoading());
    modelProfile!.block!.forEach((element) {
      if (element == phonenumber) {
        checkblock = true;
      }
    });

    emit(CheckBlockSuccess());
  }

  void block({required String phonenumber}) {
    emit(BlockUserLoading());
    FIREUSER.doc(id).update({
      "block": FieldValue.arrayUnion([phonenumber])
    }).then((value) {
      checkblock = true;
      getProfile(phonenumber: id);
      emit(BlockUserSuccess());
      print(modelProfile!.block);
    });
  }

  void unblock({required String phonenumber}) async {
    emit(UnBlockUserLoading());
    FIREUSER.doc(id).update({
      "block": FieldValue.arrayRemove([phonenumber])
    }).then((value) async {
      checkblock = false;
      modelProfile == '';
      print(modelProfile!.block);
      await getProfile(phonenumber: id);
      print(modelProfile!.block);
      emit(UnBlockUserSuccess());
    });
  }

  reportuser(String phonenumber, BuildContext context) {
    emit(ReportUserLoading());
    FIREUSER
        .doc(phonenumber)
        .collection(REPORT)
        .doc(id)
        .set({"id": id}).then((value) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.contactsreported);
      emit(ReportUserLoading());
    });
  }

  bool mute = false;
  checkmute(String phonenumber) {
    emit(CheckMuteLoading());
    FIREUSER
        .doc(id)
        .collection(MUTE)
        .where("id", isEqualTo: phonenumber)
        .snapshots()
        .listen((value) {
      mute = false;
      value.docs.forEach((element) {
        if (element.id == phonenumber) {
          mute = true;
        }
        ;
      });
    });
  }

  muteuser(String phonenumber) {
    emit(MuteUserLoading());
    print(mute);
    if (mute == false) {
      FIREUSER
          .doc(id)
          .collection(MUTE)
          .doc(phonenumber)
          .set({"id": phonenumber}).then((value) {
        emit(MuteUserSuccess());
      });
    } else {
      FIREUSER.doc(id).collection(MUTE).doc(phonenumber).delete().then((value) {
        emit(MuteUserSuccess());
      });
    }
  }

  clearchatcontent(String phonenumber, context) {
    emit(DeleteChatLoading());
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .collection(MESSAGS)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FIREUSER
            .doc(id)
            .collection(CHAT)
            .doc(phonenumber)
            .collection(MESSAGS)
            .doc(element.id)
            .delete();
      });
      Navigator.pop(context, 'Sign Out');
      emit(DeleteChatSuccess());
    });
  }

  readchat(String phonenumber) {
    emit(ReadChatLoading());
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .update({"seen": false}).then((value) {
      emit(ReadChatSuccess());
    });
  }

  unreadchat(String phonenumber) {
    emit(UnReadChatLoading());
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .update({"seen": true}).then((value) {
      FIREUSER
          .doc(phonenumber)
          .collection(CHAT)
          .doc(id)
          .collection(MESSAGS)
          .where("seen", isEqualTo: false)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          FIREUSER
              .doc(phonenumber)
              .collection(CHAT)
              .doc(id)
              .collection(MESSAGS)
              .doc(element.id)
              .update({"seen": true});
        });
        emit(UnReadChatSuccess());
      });
    });
  }

  deletechat(String phonenumber) {
    emit(DeleteMessagesLoading());
    FIREUSER.doc(id).collection(CHAT).doc(phonenumber).delete().then((value) {
      FIREUSER
          .doc(id)
          .collection(CHAT)
          .doc(phonenumber)
          .collection(MESSAGS)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          FIREUSER
              .doc(id)
              .collection(CHAT)
              .doc(phonenumber)
              .collection(MESSAGS)
              .doc(element.id)
              .delete();
        });
        emit(DeleteMessagesSuccess());
      });
    });
  }

  List<Map> MyFav = [];
  getMyFav() {
    emit(GetMyFavLoading());
    FIREUSER.doc(id).collection(MYFAV).snapshots().listen((event) {
      MyFav = [];
      event.docs.forEach((element) {
        FIREUSER.doc(element.id).get().then((value) {
          MyFav.add({
            "name": value.data()!['name'],
            "phonenumber": value.data()!['phonenumber'],
            "image": value.data()!['image'],
            "by": element.data()['by'],
          });
        });
      });
      emit(GetMyFavSuccess());
    });
  }

  List<Map> HisFav = [];

  getHisFav() {
    emit(GetHisFavLoading());
    FIREUSER.doc(id).collection(HISFAV).snapshots().listen((event) {
      MyFav = [];
      event.docs.forEach((element) {
        if (element.data()['by'] == "2") {
          FIREUSER.doc(element.id).get().then((value) {
            HisFav.add({
              "name": value.data()!['name'],
              "phonenumber": value.data()!['phonenumber'],
              "image": value.data()!['image'],
              "by": element.data()['by'],
            });
          });
        } else {
          HisFav.add({
            "name": null,
            "phonenumber": element.data()['phonenumber'],
            "image": null,
            "by": element.data()['by'],
          });
        }
      });
      emit(GetHisFavSuccess());
    });
  }

  List<Map> muted = [];
  getmute() {
    emit(GetMuteLoading());
    FIREUSER.doc(id).collection(MUTE).get().then((value) {
      muted = [];
      value.docs.forEach((element) {
        FIREUSER.doc(element.id).get().then((value) {
          muted.add(value.data()!);
          emit(GetMuteSuccess());
        });
      });
      emit(GetMuteSuccess());
    });
  }

  unmute(String muteid) {
    emit(UnMuteLoading());
    FIREUSER.doc(id).collection(MUTE).doc(muteid).delete().then((value) {
      getmute();
      emit(UnMuteSuccess());
    });
  }

  List<Map> blocked = [];
  getblock() {
    emit(GetBlockerLoading());
    FIREUSER.doc(id).get().then((value) {
      blocked = [];
      value.data()!['block'].forEach((element) {
        FIREUSER.doc(element).get().then((value) {
          blocked.add(value.data()!);
          emit(GetBlockerSuccess());
        });
      });
      emit(GetBlockerSuccess());
    });
  }

  changelang(String value, BuildContext context) {
    CacheHelper.saveData(key: "lang", value: value).then((valued) {
      lang = value;
      navof(context: context, screen: MyApp());
    });
  }

  logout(BuildContext context) {
    FIREUSER.doc(id).update({"token": null}).then((value) {
      CacheHelper.removeData(key: "id").then((value) {
        id = null;

        FirebaseAuth.instance.signOut();
        navof(context: context, screen: PhoneNumberScreen());
      });
    });
  }

  requestPermissiongallery() {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectcamera();
      }
    });
  }

  File? image;
  final ImagePicker pickerimage = ImagePicker();
  Future<void> selectcamera() async {
    final photo = await pickerimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      image = File(photo.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  editprofile({required String name, required String bio, String? image}) {
    emit(EditProfileLoading());
    FIREUSER.doc(id).update({
      "name": name,
      "bio": bio,
      "image": image != null ? image : modelProfile!.image
    }).then((value) {
      getProfile(phonenumber: id);
      emit(EditProfileSuccess());
    });
  }

  ImageProvider<Object>? imageload() {
    if (image == null) {
      return NetworkImage(modelProfile!.image!);
    } else {
      return FileImage(image!);
    }
  }

  editimage({
    required String name,
    required String bio,
  }) {
    emit(EditProfileImageLoading());
    STOAGEUSER
        .child("$id/${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((link) {
        editprofile(name: name, bio: bio, image: link);
      });
    });
  }
}

import 'dart:ffi';
import 'dart:io';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubitsaraha/states.dart';
import 'package:darkchat/model/sarahahmodel.dart';
import 'package:darkchat/model/usermodel.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/network/apinotification.dart';

class CubitSaraha extends Cubit<StatesSaraha> {
  CubitSaraha() : super(InitSarahaState());
  static CubitSaraha get(context) => BlocProvider.of(context);
  UserModel? userModel;
  void getUser({required String phonenumber}) {
    emit(GetUserSarahaLoading());
    FIREUSER.doc(phonenumber).get().then((value) {
      userModel = UserModel.fromJson(value.data()!);
      emit(GetUserSarahaSuccess());
    });
  }

  requestPermission() {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectimage();
      }
    });
  }

  File? image;
  final ImagePicker pickerimage = ImagePicker();
  Future<void> selectimage() async {
    final photo = await pickerimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      image = File(photo.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  List<SarahahModel> saraha = [];
  void getsaraha({required String phonenumber}) {
    emit(GetSarahaLoading());
    FIRESARAHAH
        .doc(phonenumber)
        .collection(MESSAGS)
        .orderBy("datetime")
        .snapshots()
        .listen((value) {
      saraha = [];
      value.docs.forEach((element) {
        saraha.add(SarahahModel.fromJson(element.data()));
      });
      emit(GetSarahaSuccess());
    });
  }

  SarahahModel? sarahahModel;
  void sendsaraha(
      {required String phonenumber,
      required String message,
      required BuildContext context,
      required String token,
      String? messageimage}) {
    emit(SendSarahaLoading());
    sarahahModel = SarahahModel(
        comment: null,
        datetime: DateTime.now().toString(),
        id: null,
        idreceived: phonenumber,
        idsender: id,
        message: message,
        seen: false,
        image: messageimage == null ? null : messageimage);
    FIRESARAHAH
        .doc(phonenumber)
        .collection(MESSAGS)
        .add(sarahahModel!.toMap())
        .then((value) {
      FIRESARAHAH
          .doc(phonenumber)
          .collection(MESSAGS)
          .doc(value.id)
          .update({"id": value.id});
      notificationmessage(
          idsarah: value.id,
          message: message,
          token: token,
          image: messageimage == null ? null : messageimage,
          context: context);
      emit(SendSarahaSuccess());
    });
  }

  uploadsarahimage(
      {required String phonenumber,
      required String token,
      required String message,
      required BuildContext context}) {
    emit(UploadImageLoading());
    STORAGESARAHAH
        .child("$phonenumber/${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        sendsaraha(
            phonenumber: phonenumber,
            message: message,
            context: context,
            messageimage: value,
            token: token);
      });
    });
  }

  notificationmessage(
      {required String message,
      required String idsarah,
      String? image,
      required var token,
      required BuildContext context}) {
    APInotification.postRequset(data: {
      "to": token,
      "notification": {"body": message, "sounde": "default", "image": image},
      "data": {
        "icon":
            "https://firebasestorage.googleapis.com/v0/b/darkchat-31673.appspot.com/o/94665.png?alt=media&token=3ee6d231-5878-4155-ae7b-59687e92fe61",
        "id": 5,
        "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
        "idsaraha": idsarah
      }
    });
  }

  String convertToAgo(DateTime input, BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    emit(ConverTimetoAgo());
    Duration diff = DateTime.now().difference(input);
    if (diff.inDays >= 1) {
      if (diff.inDays == 1) {
        return '${trans.day}';
      } else if (diff.inDays == 2) {
        return '${trans.day2}';
      } else if (diff.inDays <= 10) {
        return '${diff.inDays} ${trans.days}';
      } else {
        return '${diff.inDays} ${trans.day}';
      }
    } else if (diff.inHours >= 1) {
      if (diff.inHours == 1) {
        return '${trans.hour}';
      } else if (diff.inHours == 2) {
        return '${trans.hour2}';
      } else if (diff.inHours <= 10) {
        return '${diff.inHours} ${trans.hours}';
      } else {
        return '${diff.inHours} ${trans.hour}';
      }
    } else if (diff.inMinutes >= 1) {
      if (diff.inMinutes == 1) {
        return '${trans.minute}';
      } else if (diff.inMinutes == 2) {
        return '${trans.minute2}';
      } else if (diff.inMinutes <= 10) {
        return '${diff.inMinutes} ${trans.minutes}';
      } else {
        return '${diff.inMinutes} ${trans.minute}';
      }
    } else if (diff.inSeconds >= 1) {
      if (diff.inSeconds == 1) {
        return '${trans.second}';
      } else if (diff.inSeconds == 2) {
        return '${trans.second2}';
      } else if (diff.inSeconds <= 10) {
        return '${diff.inSeconds} ${trans.seconds}';
      } else {
        return '${diff.inSeconds} ${trans.second}';
      }
    } else {
      return 'just now';
    }
  }

  List<SarahahModel> mysaraha = [];
  getmysarah() {
    emit(GetMySarahaLoading());
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .orderBy("datetime")
        .snapshots()
        .listen((value) {
      mysaraha = [];
      value.docs.forEach((element) {
        mysaraha.add(SarahahModel.fromJson(element.data()));
      });
      emit(GetMySarahaSuccess());
    });
  }

  searchsarah(String value) {
    emit(SearchSarahaLoading());
    print(value);
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .where("message", isGreaterThanOrEqualTo: value)
        .get()
        .then((value) {
      mysaraha = [];
      value.docs.forEach((element) {
        mysaraha.add(SarahahModel.fromJson(element.data()));
      });
      emit(SearchSarahaSuccess());
    });
  }

  omchangesearch(String value) {
    if (value.isEmpty) {
      getmysarah();
    } else {
      searchsarah(value);
    }
  }

  CommentModel? commentModel;
  addcomment(
      {required String comment, String? image, required String idsaraha}) {
    commentModel = CommentModel(
        comment: comment,
        datetime: DateTime.now().toString(),
        image: image == null ? null : image);
    emit(AddCommentLoading());
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .doc(idsaraha)
        .update({"comment": commentModel!.toMap()}).then((value) {
      getsarahadetails(idsaraha);
      emit(AddCommentSuccess());
    });
  }

  uploadimagecoment({
    required String comment,
    required String idsaraha,
  }) {
    emit(UploadImageComment());
    STORAGESARAHAH
        .child("$id/${Uri.file(imagecomment!.path).pathSegments.last}")
        .putFile(imagecomment!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        addcomment(comment: comment, idsaraha: idsaraha, image: value);
      });
    });
  }

  removeimage() {
    image = null;
    imagecomment = null;
    emit(RemoveImage());
  }

  deletesaraha(String idsarah) {
    emit(DeleteSarahaLoading());
    FIRESARAHAH.doc(id).collection(MESSAGS).doc(idsarah).delete().then((value) {
      emit(DeleteSarahaSuccess());
    });
  }

  readsaraha(String idsarah) {
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .doc(idsarah)
        .update({"seen": true}).then((value) {
      emit(ReadSarahaSuccess());
    });
  }

  unreadsaraha(String idsarah) {
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .doc(idsarah)
        .update({"seen": false}).then((value) {
      emit(UnReadSarahaSuccess());
    });
  }

  Map sarahadet = {};
  getsarahadetails(String idsarah) {
    emit(GetSarahaDetLoading());
    FIRESARAHAH.doc(id).collection(MESSAGS).doc(idsarah).get().then((value) {
      sarahadet.addAll(value.data()!);
      emit(GetSarahaDetSuccess());
    });
  }

  gallerypermission() {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectimagecomment();
      }
    });
  }

  File? imagecomment;
  final ImagePicker pickerimagecomment = ImagePicker();
  Future<void> selectimagecomment() async {
    final photo =
        await pickerimagecomment.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      imagecomment = File(photo.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  deletecomment(String idsaraha, BuildContext context) {
    emit(DeleteCommentLoading());
    FIRESARAHAH
        .doc(id)
        .collection(MESSAGS)
        .doc(idsaraha)
        .update({"comment": null}).then((value) {
      getsarahadetails(idsaraha);
      Navigator.pop(context, 'Sign Out');
      emit(DeleteCommentSuccess());
    });
  }
}

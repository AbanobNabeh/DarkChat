import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/constants/network/apinotification.dart';
import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/view/screen/chat/documentsend.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/model/chatlistmodel.dart';
import 'package:darkchat/model/messagemodel.dart';
import 'package:darkchat/model/usermodel.dart';
import 'package:darkchat/view/screen/chat/fullscreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class CubitChat extends Cubit<StatesChat> {
  CubitChat() : super(InitAuthState());
  static CubitChat get(context) => BlocProvider.of(context);

  bool isType = false;
  istype(String value) {
    if (value.isNotEmpty) {
      isType = true;
    } else {
      isType = false;
    }
    emit(ChangeIsType());
  }

  ChatListModel? chatListModel;
  messagedata(
      {required String message,
      required String phonenumber,
      required String name,
      required String imageuser,
      required BuildContext context,
      String? messageimage,
      String? messagerecord,
      DocumentModel? document,
      String? namerec}) {
    emit(SendMessageLoading());
    chatListModel = ChatListModel(
        name: name,
        imageuser: imageuser,
        phonenumber: phonenumber,
        datatime: DateTime.now().toString(),
        lastmessage: message,
        recored: namerec != null ? namerec : null,
        messageimage: messageimage != null ? messageimage : null,
        document: document != null ? document.name : null,
        seen: true);
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .set(chatListModel!.toMap())
        .then((value) {
      chatListModel = ChatListModel(
          name: CubitHome.get(context).modelProfile!.name,
          imageuser: CubitHome.get(context).modelProfile!.image,
          phonenumber: id,
          datatime: DateTime.now().toString(),
          lastmessage: message,
          recored: namerec != null ? namerec : null,
          messageimage: messageimage != null ? messageimage : null,
          document: document != null ? document.name : null,
          seen: false);
      FIREUSER
          .doc(phonenumber)
          .collection(CHAT)
          .doc(id)
          .set(chatListModel!.toMap());
      sendmessage(
        message: message,
        phonenumber: phonenumber,
        messageimage: messageimage == null ? null : messageimage,
        messagerecord: messagerecord == null ? null : messagerecord,
        document: document == null ? null : document,
        context: context,
      );
      snednotification(
          token: userchat['token'],
          message: document != null
              ? document.name!
              : messagerecord != null
                  ? "\ud83c\udfa4 $namerec"
                  : message,
          name: CubitHome.get(context).modelProfile!.name!,
          phonenumber: phonenumber,
          image: messageimage == null ? null : messageimage,
          context: context);
    });
  }

  MessageModel? messageModel;
  sendmessage(
      {required String message,
      required String phonenumber,
      String? messageimage,
      String? messagerecord,
      DocumentModel? document,
      required BuildContext context}) {
    emit(SendMessageLoading());
    messageModel = MessageModel(
        datetime: DateTime.now().toString(),
        idmessage: null,
        idreceived: phonenumber,
        idsender: id,
        message: message,
        messageimage: messageimage == null ? null : messageimage,
        messagerecord: messagerecord == null ? null : messagerecord,
        document: document == null ? null : document,
        seen: false,
        replay: replaymessage);
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .collection(MESSAGS)
        .add(messageModel!.toMap())
        .then((idsender) {
      messageModel = MessageModel(
          datetime: DateTime.now().toString(),
          idmessage: idsender.id,
          idreceived: phonenumber,
          idsender: id,
          message: message,
          messageimage: messageimage == null ? null : messageimage,
          messagerecord: messagerecord == null ? null : messagerecord,
          document: document == null ? null : document,
          seen: true,
          replay: replaymessage);
      FIREUSER
          .doc(phonenumber)
          .collection(CHAT)
          .doc(id)
          .collection(MESSAGS)
          .doc(idsender.id)
          .set(messageModel!.toMap());
      FIREUSER
          .doc(id)
          .collection(CHAT)
          .doc(phonenumber)
          .collection(MESSAGS)
          .doc(idsender.id)
          .update({"idmessage": idsender.id});
      removereplay();

      emit(SendMessageSuccess());
    }).catchError((error) {
      emit(SendMessageError());
    });
  }

  Map userchat = {};
  getuser({required String phonenumber}) {
    emit(GetUseerLoading());
    FIREUSER.doc(phonenumber).snapshots().listen((event) {
      userchat.addAll(event.data()!);
      checkblock(phonenumber);
      emit(GetUserSuccess());
    });
  }

  Map playlist = {};
  List<MessageModel> message = [];
  List messageimage = [];
  void getMessages({
    required String receiverId,
  }) {
    emit(GetMessageLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('chat')
        .doc(receiverId)
        .collection('messages')
        .orderBy("datetime")
        .snapshots()
        .listen((event) {
      message = [];
      playlist = {};
      messageimage = [];
      event.docs.reversed.forEach((element) {
        if (element.data()['messageimage'] != null) {
          messageimage.add(element.data());
        }
        message.add(MessageModel.fromJson(element.data()));
        playlist.addAll({element.data()['messagerecord']: false});
      });
      getuser(phonenumber: receiverId);
      emit(GetMessageSuccess());
    });
  }

  List<ChatListModel> chatlist = [];
  getuserschat() {
    emit(GetChatListLoading());
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .orderBy("datatime")
        .snapshots()
        .listen((event) {
      chatlist = [];
      event.docs.reversed.forEach((element) {
        chatlist.add(ChatListModel.fromJson(element.data()));
      });
      emit(GetChatListSuccess());
    });
  }

  bool emojihide = true;
  emoji() {
    emojihide = !emojihide;
    emit(ChangeEmoji());
  }

  requestPermissioncamera({required BuildContext context, phonenumber}) {
    Permission.camera.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectcamera(context: context, phonenumber: phonenumber);
      }
    });
  }

// MenuChatPicker
  File? image;
  final ImagePicker pickerimage = ImagePicker();
  Future<void> selectcamera(
      {required BuildContext context, phonenumber}) async {
    final photo = await pickerimage.pickImage(source: ImageSource.camera);
    if (photo != null) {
      image = File(photo.path);
      navto(context: context, screen: FullScreen(image, phonenumber));
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  requestPermissiongallery({required BuildContext context, phonenumber}) {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectgallery(context: context, phonenumber: phonenumber);
      }
    });
  }

  Future<void> selectgallery(
      {required BuildContext context, phonenumber}) async {
    final photo = await pickerimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      image = File(photo.path);
      navto(context: context, screen: FullScreen(image, phonenumber));
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  Future<void> filepicker({
    required BuildContext context,
    required String phonenumber,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (file != null) {
      image = File(file.files.single.path!);
      navto(context: context, screen: DocumentSend(image, phonenumber));
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  uploaddocument(image, phonenumber, context, name, imageuser) {
    emit(UploadDocumentLoading());
    STOAGEUSER
        .child(id)
        .child("$CHAT/${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((link) {
        messagedata(
            message: '',
            document: DocumentModel(
                link: link, name: value.ref.name, bytes: value.totalBytes),
            phonenumber: phonenumber,
            name: name,
            imageuser: imageuser,
            context: context);
        Navigator.pop(context);
      });
    });
  }
// END

  uploadimagechat({
    required String phonenumber,
    required String message,
    required BuildContext context,
    required String imageuser,
    required String name,
    required File image,
  }) {
    emit(UploadImageLoading());
    STOAGEUSER
        .child(id)
        .child("$CHAT/${Uri.file(image.path).pathSegments.last}")
        .putFile(image)
        .then((value) {
      value.ref.getDownloadURL().then((link) {
        messagedata(
            message: message,
            phonenumber: phonenumber,
            name: name,
            imageuser: imageuser,
            context: context,
            messageimage: link);
        Navigator.pop(context);
      });
    }).catchError((onError) {});
  }

  isseen({required String phonenumber}) {
    emit(ChangeSeenLoading());
    FIREUSER
        .doc(phonenumber)
        .collection(CHAT)
        .doc(id)
        .collection(MESSAGS)
        .where("seen", isEqualTo: false)
        .get()
        .then((event) {
      event.docs.forEach((element) {
        FIREUSER
            .doc(phonenumber)
            .collection(CHAT)
            .doc(id)
            .collection(MESSAGS)
            .doc(element.id)
            .update({"seen": true});
      });
      FIREUSER.doc(id).collection(CHAT).doc(phonenumber).update({"seen": true});
      emit(ChangeSeenSuccess());
    });
  }

  // Mic
  bool isRecording = false;
  bool isPaused = false;
  int recordDuration = 0;
  Timer? timer;
  Timer? ampTimer;
  final audioRecorder = Record();
  Amplitude? amplitude;

  Future<void> start() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final isSupported = await audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {}
        await audioRecorder.start();
        bool isRecordingnow = await audioRecorder.isRecording();
        isRecording = isRecordingnow;
        recordDuration = 0;
        startTimer();
        emit(StopRecordingState());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> stop({
    required String message,
    required String phonenumber,
    required String name,
    required String imageuser,
    required BuildContext context,
  }) async {
    emit(StopRecordingStateLoading());
    timer?.cancel();
    ampTimer?.cancel();
    final path = await audioRecorder.stop();
    STOAGEUSER
        .child(phonenumber)
        .child("$CHAT/${Uri.file(path!).pathSegments.last}")
        .putFile(File(path))
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        messagedata(
            message: message,
            phonenumber: phonenumber,
            name: name,
            imageuser: imageuser,
            context: context,
            messagerecord: value,
            namerec: "${Uri.file(path).pathSegments.last}");
      });
      isRecording = false;
      emit(StopRecordingState());
    });
  }

  Future<void> removerecord() async {
    emit(StopRecordingStateLoading());
    timer?.cancel();
    ampTimer?.cancel();
    final path = await audioRecorder.stop();
    isRecording = false;
    emit(RemoveRecordingState());
  }

  void startTimer() {
    timer?.cancel();
    ampTimer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      recordDuration++;
    });
    ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      amplitude = await audioRecorder.getAmplitude();
    });
    emit(ChangeTime());
  }

  String formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }
    emit(ChangeTime());
    return numberStr;
  }

  Widget buildTimer() {
    final String minutes = formatNumber(recordDuration ~/ 60);
    final String seconds = formatNumber(recordDuration % 60);
    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: defcolor),
    );
  }

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final audioplayer = AudioPlayer();
  isplaying(audio) async {
    emit(PlayerLoading());
    playlist.updateAll((key, value) => false);
    if (isPlaying) {
      await audioplayer.pause();
      emit(PausePlayer());
    } else {
      playlist.update(audio, (value) => true);
      await audioplayer.setSourceUrl(audio);
      await audioplayer.resume();
      emit(StartPlayer());
    }
  }

  String formatTime(Duration duration) {
    String twodigits(int n) => n.toString().padLeft(2, "0");
    final hours = twodigits(duration.inHours);
    final inMinutes = twodigits(duration.inMinutes.remainder(60));
    final inSeconds = twodigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, inMinutes, inSeconds].join(":");
  }

  void initstate() {
    audioplayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      emit(OnPlayerStateChangedSuccess());
    });
    audioplayer.onDurationChanged.listen((durationstate) {
      duration = durationstate;
      emit(OnDurationChangedSuccess());
    });
    audioplayer.onPositionChanged.listen((state) {
      position = state;
      print(state);
      emit(OnPositionChangedSuccess());
    });
    audioplayer.onPlayerComplete.listen((event) {
      playlist.updateAll((key, value) => false);
      audioplayer.pause();
      emit(OnPlayerCompleteSuccess());
    });
  }

  slideronchange(value) async {
    final position = Duration(seconds: value.toInt());
    audioplayer.seek(position);
    audioplayer.resume();
    emit(OnChangeSlider());
  }

  deletemessage(
      {required String phonenumber,
      required String idmessage,
      int? forme,
      required BuildContext context}) {
    emit(DeleteMessageLoading());
    if (forme == 1) {
      FIREUSER
          .doc(id)
          .collection(CHAT)
          .doc(phonenumber)
          .collection(MESSAGS)
          .doc(idmessage)
          .delete();
    } else {
      FIREUSER
          .doc(id)
          .collection(CHAT)
          .doc(phonenumber)
          .collection(MESSAGS)
          .doc(idmessage)
          .delete()
          .then((value) {
        FIREUSER
            .doc(phonenumber)
            .collection(CHAT)
            .doc(id)
            .collection(MESSAGS)
            .doc(idmessage)
            .delete();
      });
    }

    emit(DeleteMessageSuccess());
    Navigator.pop(context);
  }

  String formatSizefile(int bytes, BuildContext context) {
    double kilobyte = 1024;
    double megabyte = kilobyte * 1024;
    double gigabyte = megabyte * 1024;
    double terabyte = gigabyte * 1024;
    var trans = AppLocalizations.of(context)!;
    if (bytes < 1024) {
      return "$bytes ${trans.byte}";
    } else if (bytes < 1048629) {
      double x = bytes / kilobyte;
      return "${x.toStringAsFixed(x.truncateToDouble() == x ? 0 : 2)} ${trans.kb}";
    } else if (bytes < 1073795512) {
      double x = bytes / megabyte;
      return "${x.toStringAsFixed(x.truncateToDouble() == x ? 0 : 2)} ${trans.mb}";
    } else if (bytes < 1099511627776) {
      double x = bytes / gigabyte;
      return "${x.toStringAsFixed(x.truncateToDouble() == x ? 0 : 2)} ${trans.gb}";
    } else if (bytes >= 1099511627776) {
      double x = bytes / terabyte;
      return "${x.toStringAsFixed(x.truncateToDouble() == x ? 0 : 2)} ${trans.tb}";
    }
    return "$bytes ${trans.byte}";
  }

  savephoto(String url, BuildContext context) async {
    GallerySaver.saveImage(url, albumName: "DarkChat").then((value) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.saveimage);
      Navigator.pop(context);
    });
  }

  List sharemedie = [];
  List<DocumentModel> sharemediedocument = [];
  getimage(String phonenumber) {
    emit(GetShareMediaLoading());
    FIREUSER
        .doc(id)
        .collection(CHAT)
        .doc(phonenumber)
        .collection(MESSAGS)
        .orderBy("datetime")
        .get()
        .then((value) {
      sharemedie = [];
      sharemediedocument = [];
      value.docs.forEach((element) {
        if (element.data()['messageimage'] != null) {
          sharemedie.add(element.data());
        } else if (element.data()['document'] != null) {
          sharemediedocument
              .add(DocumentModel.fromJson(element.data()['document']));
        }
      });
      print(sharemediedocument);
      emit(GetShareMediaSuccess());
    });
  }

  Map? replaymessage;

  void replay(Map message) {
    emit(ReplayMessaghChange());
    replaymessage = message;
  }

  void removereplay() {
    replaymessage = null;
    emit(RemoveReplay());
  }

  bool block = false;
  checkblock(phonenumber) {
    block = false;
    emit(CheckBlocLoading());
    userchat['block'].forEach((element) {
      if (element == id) {
        block = true;
      }
    });
  }

  bool meblock = false;
  checkblockme(String phonenumber) {
    emit(CheckBlocMELoading());
    FIREUSER.doc(id).get().then((value) {
      meblock = false;
      value.data()!['block'].forEach((element) {
        if (element == phonenumber) {
          meblock = true;
        }
      });
      emit(CheckBlocMESuccess());
    });
  }

  void snednotification(
      {required String token,
      required String message,
      required String name,
      required String phonenumber,
      required BuildContext context,
      String? image}) {
    String? Icon = CubitHome.get(context).modelProfile!.image;
    emit(SendNotificationLoading());
    FIREUSER
        .doc(phonenumber)
        .collection(MUTE)
        .where("id", isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        APInotification.postRequset(data: {
          "to": token,
          "notification": {
            "title": name,
            "body": message,
            "image": image,
            "sounde": "default",
          },
          "data": {
            "icon": Icon,
            'id': 1,
            "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
            "phonenumber": id
          }
        });
      }
      emit(SendNotificationSuccess());
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
}

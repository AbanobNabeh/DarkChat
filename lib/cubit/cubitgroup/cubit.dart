import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:darkchat/model/messagegroupmodel.dart';
import 'package:darkchat/model/messagemodel.dart';
import 'package:darkchat/view/screen/group/documentsend.dart';
import 'package:darkchat/view/screen/group/sendphoto.dart';
import 'package:darkchat/view/screen/homepage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/cubit/cubitgroup/states.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/model/grouplistmodel.dart';
import 'package:darkchat/model/modelgroup.dart';
import 'package:darkchat/view/screen/group/addusers.dart';
import 'package:darkchat/view/screen/group/groupscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../constants/network/apinotification.dart';

class CubitGroup extends Cubit<StatesGroup> {
  CubitGroup() : super(InitGroupState());
  static CubitGroup get(context) => BlocProvider.of(context);
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  requestPermission({required BuildContext context, phonenumber}) {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectcamera(context: context, phonenumber: phonenumber);
      }
    });
  }

  File? image;
  final ImagePicker pickerimage = ImagePicker();
  Future<void> selectcamera(
      {required BuildContext context, phonenumber}) async {
    final photo = await pickerimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      image = File(photo.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  ModelGroup? modelGroup;
  creategroup(
      {required String name,
      required String description,
      String? image,
      required BuildContext context}) {
    modelGroup = ModelGroup(
        canadd: "admin",
        cansendmessage: "anyone",
        createdby: id,
        date: DateTime.now().toString(),
        datecreategroup: DateTime.now().toString(),
        time: DateTime.now().toString(),
        description: description,
        image: image != null
            ? image
            : "https://firebasestorage.googleapis.com/v0/b/darkchat-31673.appspot.com/o/logo.png?alt=media&token=6b777670-1289-4969-98fb-9cf7b8490892",
        lastmessage: "Create New Group By $id",
        name: name,
        topic: getRandomString(45),
        id: null,
        members: [
          {
            "state": "leader",
            "phonenumber": id,
          }
        ],
        seen: [
          id
        ]);
    emit(CreateGroupLoading());
    FIREGROUP.add(modelGroup!.toMap()).then((value) {
      FIREGROUP.doc(value.id).update({"id": value.id});
      FirebaseMessaging.instance.subscribeToTopic(modelGroup!.topic!);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AddUsersScreen(value.id)));
      emit(CreateGroupSuccess());
    });
  }

  uploadimagegroup(
      {required String name,
      required String description,
      required BuildContext context}) {
    emit(UploadImageLoading());
    STORAGEGROUP
        .child("/${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        creategroup(
            name: name,
            description: description,
            image: value,
            context: context);
      });
    });
  }

  List<Map> users = [];
  getUsers() {
    emit(SelectUserLoading());
    FIREUSER.doc(id).collection(CHAT).get().then((value) {
      users = [];
      value.docs.forEach((element) {
        FIREUSER.doc(element.id).get().then((value) {
          users.add({
            "name": element['name'],
            "image": element['imageuser'],
            "phonenumber": element['phonenumber'],
            "token": value['token'],
            "select": false
          });
          emit(SelectUserSuccess());
        });
      });
    });
  }

  selectuser(index) {
    users[index].update("select", (value) => !users[index]['select']);
    emit(SelectUser());
  }

  addmember(String idgroup, context) {
    emit(AddMemberLoading());
    users.forEach((element) {
      if (element['select'] == true) {
        FIREGROUP.doc(idgroup).update({
          "members": FieldValue.arrayUnion([
            {
              "phonenumber": element['phonenumber'],
              "state": "request",
            }
          ])
        }).then((value) {
          emit(AddMemberSuccess());
        });
      }
    });
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GroupScreen(idgroup)));
  }

  sendnotification(BuildContext context, List item, var select) {
    item.forEach((element) {
      if (element['select'] == select) {
        String token = element['token'];
        APInotification.postRequset(data: {
          "to": token,
          "notification": {
            "title": "${CubitHome.get(context).modelProfile!.name}",
            "body": "I Send You An invitation to join the new group",
            "sounde": "default",
          },
          "data": {
            "icon": CubitHome.get(context).modelProfile!.image,
            'id': 2,
            "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
          }
        });
      }
    });
  }

  Map group = {};
  getGroupinfo(String idgroup) {
    emit(GetGroupLoading());
    FIREGROUP.doc(idgroup).snapshots().listen((event) {
      group = {};
      group.addAll(event.data()!);
      chackme(event.data()!['members']);
      emit(GetGroupSuccess());
    });
  }

  Map me = {};
  chackme(memeber) {
    memeber.forEach((element) {
      if (element['phonenumber'] == id) {
        me.addAll(element);
      }
    });
  }

  List<ModelGroupList> groups = [];
  List<ModelGroupList> requests = [];
  Map seen = {};
  getGroups() {
    emit(GetGroupsListLoading());
    FIREGROUP.orderBy("time").snapshots().listen((event) {
      groups = [];
      requests = [];
      seen = {};
      event.docs.reversed.forEach((data) {
        data['members'].forEach((element) {
          if (element['phonenumber'] == id) {
            if (element['state'] != "request") {
              groups.add(ModelGroupList.fromJson(data.data()));
              seen.addAll({data.id: false});
              data.data()['seen'].forEach((element) {
                if (element == id) {
                  seen.update(data.id, (value) => true);
                }
              });
            } else {
              requests.add(ModelGroupList.fromJson(data.data()));
            }
          }
        });
      });
      emit(GetGroupsListSuccess());
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

  acceptrequest(String idgroup, topic) {
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {"phonenumber": id, "state": "request"}
      ])
    }).then((value) {
      FIREGROUP.doc(idgroup).update({
        "members": FieldValue.arrayUnion([
          {"phonenumber": id, "state": "member"}
        ])
      });
      FirebaseMessaging.instance.subscribeToTopic(topic);
    });
  }

  declinedrequest(String idgroup) {
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {"phonenumber": id, "state": "request"}
      ])
    });
  }

  bool emojihide = true;
  emoji() {
    emojihide = !emojihide;
    emit(ChangeEmoji());
  }

  bool isType = false;
  istype(String value) {
    if (value.isNotEmpty) {
      isType = true;
    } else {
      isType = false;
    }
    emit(ChangeIsType());
  }

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

  Future<void> removerecord() async {
    emit(StopRecordingStateLoading());
    timer?.cancel();
    ampTimer?.cancel();
    final path = await audioRecorder.stop();
    isRecording = false;
    emit(RemoveRecordingState());
  }

  MessageGroupModel? messageGroupModel;
  sendmessage({
    required String message,
    required BuildContext context,
    required String idgroup,
    String? messageimage,
    String? messagerecord,
    String? namerec,
    Map? document,
  }) {
    messageGroupModel = MessageGroupModel(
        document: document != null ? document : null,
        idsender: id,
        imagesender: CubitHome.get(context).modelProfile!.image,
        message: message,
        messageimage: messageimage != null ? messageimage : null,
        messagerecord: messagerecord != null ? messagerecord : null,
        namesender: CubitHome.get(context).modelProfile!.name,
        seen: [],
        time: DateTime.now().toString(),
        id: null,
        replay: replaymessage != null ? replaymessage : null);
    FIREGROUP
        .doc(idgroup)
        .collection(MESSAGS)
        .add(messageGroupModel!.toMap())
        .then((value) {
      FIREGROUP
          .doc(idgroup)
          .collection(MESSAGS)
          .doc(value.id)
          .update({"id": value.id}).then((value) {
        FIREGROUP.doc(idgroup).update({
          "lastmessage": message,
          "messageimage": messageimage != null ? messageimage : null,
          "messagerecord": messagerecord != null ? namerec : null,
          "document": document != null ? document['name'] : null,
          "idsender": id,
          "namesender": CubitHome.get(context).modelProfile!.name,
          "time": DateTime.now().toString(),
          "seen": [id]
        }).then((value) {
          sendnotificationmessage(
              topic: group['topic'],
              idgroup: idgroup,
              namegroup: group['name'],
              image: messageimage != null ? messageimage : null,
              message: document != null
                  ? document['name']!
                  : messagerecord != null
                      ? "\ud83c\udfa4 $namerec"
                      : message,
              context: context,
              imagegroup: group['image']);
          emit(SendMessageSuccess());
        });
      });
    });
  }

  Future<void> stop({
    required String message,
    required BuildContext context,
    required String idgroup,
  }) async {
    emit(StopRecordingStateLoading());
    timer?.cancel();
    ampTimer?.cancel();
    final path = await audioRecorder.stop();
    STORAGEGROUP
        .child("${Uri.file(path!).pathSegments.last}")
        .putFile(File(path))
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        sendmessage(
            message: message,
            context: context,
            idgroup: idgroup,
            namerec: "${Uri.file(path).pathSegments.last}",
            messagerecord: value);
      });
      isRecording = false;
      emit(StopRecordingState());
    });
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

  List<MessageGroupModel> messages = [];
  Map playlist = {};

  List sharemedie = [];
  List<DocumentModel> sharemediedocument = [];
  getmessages(String idgroup) {
    emit(GetMessageLoading());
    FIREGROUP
        .doc(idgroup)
        .collection(MESSAGS)
        .orderBy("time")
        .snapshots()
        .listen((event) {
      messages = [];
      playlist = {};
      event.docs.reversed.forEach((element) {
        messages.add(MessageGroupModel.fromJson(element.data()));
        playlist.addAll({element.data()['messagerecord']: false});
      });
      emit(GetMessageSuccess());
    });
  }

  getimage(String idgroup) {
    emit(GetShareMediaLoading());
    FIREGROUP
        .doc(idgroup)
        .collection(MESSAGS)
        .orderBy("time")
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

  String formatTime(Duration duration) {
    String twodigits(int n) => n.toString().padLeft(2, "0");
    final hours = twodigits(duration.inHours);
    final inMinutes = twodigits(duration.inMinutes.remainder(60));
    final inSeconds = twodigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, inMinutes, inSeconds].join(":");
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

  slideronchange(value) async {
    final position = Duration(seconds: value.toInt());
    audioplayer.seek(position);
    audioplayer.resume();
    emit(OnChangeSlider());
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

  Map? replaymessage;
  void replay(Map message) {
    emit(ReplayMessaghChange());
    replaymessage = message;
  }

  void removereplay() {
    replaymessage = null;
    emit(RemoveReplay());
  }

  requsetsendcamera({required BuildContext context, required String idgroup}) {
    Permission.camera.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        sendCamera(context: context, idgroup: idgroup);
      }
    });
  }

  File? camerafill;
  final ImagePicker pickercamerafill = ImagePicker();
  Future<void> sendCamera(
      {required BuildContext context, required String idgroup}) async {
    final photo = await pickerimage.pickImage(source: ImageSource.camera);
    if (photo != null) {
      image = File(photo.path);
      navto(context: context, screen: FullScreen(image, idgroup));
      emit(ImageSuccess());
    } else {
      emit(ImageError());
    }
  }

  requsetsendimage({required BuildContext context, required String idgroup}) {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectimage(context: context, idgroup: idgroup);
      }
    });
  }

  File? imagefill;
  final ImagePicker pickerimagefill = ImagePicker();
  Future<void> selectimage(
      {required BuildContext context, required String idgroup}) async {
    final photo = await pickerimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      image = File(photo.path);
      navto(context: context, screen: FullScreen(image, idgroup));
      emit(ImageSuccess());
    } else {
      emit(ImageError());
    }
  }

  sendimage({
    required String idgroup,
    required String message,
    required BuildContext context,
    required File image,
  }) {
    emit(SendImageLoading());
    STORAGEGROUP
        .child("${Uri.file(image.path).pathSegments.last}")
        .putFile(image)
        .then((value) {
      value.ref.getDownloadURL().then((link) async {
        await sendmessage(
            message: message,
            context: context,
            idgroup: idgroup,
            messageimage: link);
      });
    }).catchError((onError) {});
  }

  Future<void> filepicker({
    required BuildContext context,
    required String idgroup,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (file != null) {
      image = File(file.files.single.path!);
      navto(context: context, screen: DocumentSend(image, idgroup));
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  uploaddocument(image, idgroup, context) {
    emit(UploadDocumentLoading());
    STORAGEGROUP
        .child("${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((link) {
        sendmessage(message: "", context: context, idgroup: idgroup, document: {
          "link": link,
          "name": value.ref.name,
          "bytes": value.totalBytes
        });
      });
    });
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

  bool mute = false;

  checkmute(String idgroup) {
    emit(CheckMuteGroup());
    FIREGROUP.doc(idgroup).collection(MUTE).snapshots().listen((event) {
      event.docs.forEach((element) {
        if (element.id == id) {
          mute = true;
        }
      });
      emit(CheckMuteGroupSuccess());
    });
  }

  muteGroup(String idgroup) {
    emit(MuteGroupLoding());
    if (mute == false) {
      FIREGROUP
          .doc(idgroup)
          .collection(MUTE)
          .doc(id)
          .set({"id": id}).then((value) {
        FirebaseMessaging.instance.unsubscribeFromTopic(group['topic']);
        emit(MuteGroupSuccess());
      });
    } else {
      FIREGROUP.doc(idgroup).collection(MUTE).doc(id).delete().then((value) {
        FirebaseMessaging.instance.subscribeToTopic(group['topic']);
        mute = false;
        emit(MuteGroupSuccess());
      });
    }
  }

  List members = [];
  getmembers(String idgroup) {
    emit(GetMembersLoading());
    FIREGROUP.doc(idgroup).get().then((value) {
      group = {};
      group.addAll(value.data()!);
      chackme(value.data()!['members']);
      members = [];
      value.data()!['members'].forEach((element) {
        FIREUSER.doc(element['phonenumber']).get().then((value) {
          members.add(value.data());
        });
      });
      emit(GetMembersSuccess());
    });
  }

  List profilemember = [];
  getprofilemember(String idgroup) {
    emit(GetProfileMemberLoading());
    FIREGROUP.doc(idgroup).get().then((value) {
      profilemember = [];
      value.data()!["members"].forEach((element) {
        FIREUSER.doc(element['phonenumber']).get().then((value) {
          profilemember.add({
            "name": value.data()!['name'],
            "image": value.data()!['image'],
            "phonenumber": value.data()!['phonenumber'],
            "state": element['state']
          });

          emit(GetProfileMemberSuccess());
        });
      });
    });
  }

  List myuser = [];
  getusers(String idgroup) {
    myuser = [];
    emit(GetUsersLoading());
    FIREGROUP.doc(idgroup).get().then((value) {
      value['members'].forEach((element) {
        myuser.add(element['phonenumber']);
      });
      checkmember(idgroup);
    });
  }

  List<Map> newMember = [];
  checkmember(String idgroup) {
    FIREUSER.doc(id).collection(CHAT).get().then((value) {
      newMember = [];
      value.docs.forEach((element) {
        print("This Tokne = ${element.data()['token']}");
        if (myuser.contains(element.id)) {
          FIREUSER.doc(element.id).get().then((value) {
            newMember.add({
              "image": value.data()!['image'],
              "name": value.data()!['name'],
              "phonenumber": value.data()!['phonenumber'],
              "token": value.data()!['token'],
              "select": 'old',
            });

            emit(GetUsersSuccess());
          });
        } else {
          FIREUSER.doc(element.id).get().then((value) {
            newMember.add({
              "image": value.data()!['image'],
              "name": value.data()!['name'],
              "phonenumber": value.data()!['phonenumber'],
              "token": value.data()!['token'],
              "select": 'new',
            });

            emit(GetUsersSuccess());
          });
        }
      });
    });
  }

  selectnewmemeber(index) {
    newMember[index].update("select",
        (value) => newMember[index]['select'] == "select" ? "new" : "select");
    emit(SelectNewMember());
  }

  addnewmember(String idgroup, BuildContext context) {
    emit(AddNewMemberLoading());
    newMember.forEach((element) {
      if (element['select'] == "select") {
        FIREGROUP.doc(idgroup).update({
          "members": FieldValue.arrayUnion([
            {
              "phonenumber": element['phonenumber'],
              "state": "request",
            }
          ])
        }).then((value) {
          emit(AddNewMemberSuccess());
        });
      }
    });
  }

  addadmin({required String idgroup, required String id}) {
    emit(AddAdminLoading());
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {"phonenumber": id, "state": "member"}
      ])
    }).then((value) {
      FIREGROUP.doc(idgroup).update({
        "members": FieldValue.arrayUnion([
          {"phonenumber": id, "state": "admin"}
        ])
      });
      getprofilemember(idgroup);
      emit(AddAdminSuccess());
    });
  }

  removeadmin({required String idgroup, required String id}) {
    emit(RemoveAdminLoading());
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {"phonenumber": id, "state": "admin"}
      ])
    }).then((value) async {
      FIREGROUP.doc(idgroup).update({
        "members": FieldValue.arrayUnion([
          {"phonenumber": id, "state": "member"}
        ])
      });
      getprofilemember(idgroup);
      emit(RemoveAdminSuccess());
    });
  }

  removemember(
      {required String idgroup,
      required String id,
      required String state,
      required BuildContext context}) {
    emit(RemoveMemberLoading());
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {"phonenumber": id, "state": state}
      ])
    }).then((value) {
      FIREUSER.doc(id).get().then((token) {
        FIREGROUP.doc(idgroup).get().then((value) {
          APInotification.postRequset(data: {
            "to": "${token.data()!['token']}",
            "notification": {
              "title": value.data()!['name'],
              "body":
                  "You have been removed from the group by ${CubitHome.get(context).modelProfile!.name}",
              "sounde": "default",
            },
            "data": {
              'topic': "${value.data()!['topic']}",
              "icon": value.data()!['image'],
              'id': 3,
              "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
            }
          });
          getprofilemember(idgroup);
          emit(RemoveMemberSuccess());
        });
      });
    });
  }

  reportgroup(String idgroup, BuildContext context) {
    emit(ReportGroupLoading());
    FIREGROUP
        .doc(idgroup)
        .collection(REPORT)
        .doc(id)
        .set({"id": id}).then((value) {
      Navigator.pop(context, 'cancel');
      emit(ReportGroupSuccess());
    });
  }

  canadd(String idgroup, String value) {
    FIREGROUP.doc(idgroup).update({"canadd": value}).then((value) {});
  }

  cansendmessage(String idgroup, String value) {
    FIREGROUP.doc(idgroup).update({"cansendmessage": value}).then((value) {});
  }

  removeGroup(String idgroup, BuildContext context) {
    FIREGROUP.doc(idgroup).delete().then((value) {
      navof(context: context, screen: HomePage());
    });
  }

  requseteditimage() {
    Permission.storage.request().then((status) {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        editimagepicker();
      }
    });
  }

  File? editimage;
  final ImagePicker pickereditimage = ImagePicker();
  Future<void> editimagepicker() async {
    final photo = await pickereditimage.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      editimage = File(photo.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  ImageProvider<Object>? imageload() {
    if (editimage == null) {
      return NetworkImage(group['image']);
    } else {
      return FileImage(editimage!);
    }
  }

  editGroup(
      {required String idgroup,
      String? name,
      String? description,
      String? image}) {
    emit(EditGroupLoading());
    FIREGROUP.doc(idgroup).update({
      "name": name,
      "description": description,
      "image": image != null ? image : group['image']
    }).then((value) {
      getGroupinfo(idgroup);
      emit(EditGroupSuccess());
    });
  }

  editgroupimage({
    required String idgroup,
    String? name,
    String? description,
  }) {
    emit(EditGroupimageLoading());
    STORAGEGROUP
        .child("/${Uri.file(editimage!.path).pathSegments.last}")
        .putFile(editimage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        editGroup(
            idgroup: idgroup,
            name: name,
            description: description,
            image: value);
      });
    });
  }

  leavegroup(String idgroup, BuildContext context) {
    emit(LeaveGroupLoading());
    FIREGROUP.doc(idgroup).update({
      "members": FieldValue.arrayRemove([
        {
          "phonenumber": id,
          "state": me['state'],
        }
      ])
    }).then((value) {
      FirebaseMessaging.instance.unsubscribeFromTopic(group['topic']);
      navof(context: context, screen: HomePage());
      emit(LeaveGroupSuccess());
    });
  }

  savephoto(String url, BuildContext context, bool back) async {
    GallerySaver.saveImage(url, albumName: "DarkChat").then((value) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.saveimage);
      back == false ? null : Navigator.pop(context);
    });
  }

  deletemessage(
      {required String idgroup,
      required String idmessage,
      required BuildContext context}) {
    FIREGROUP
        .doc(idgroup)
        .collection(MESSAGS)
        .doc(idmessage)
        .delete()
        .then((value) {
      Navigator.pop(context);
    });
  }

  seenmessage(String idgroup) {
    FIREGROUP.doc(idgroup).update({
      "seen": FieldValue.arrayUnion([id])
    }).then((value) {});
  }

  sendnotificationmessage(
      {required String topic,
      required String namegroup,
      required String imagegroup,
      required String idgroup,
      required String message,
      required BuildContext context,
      String? image}) {
    APInotification.postRequset(data: {
      "to": "/topics/$topic",
      "notification": {
        "title": namegroup,
        "body": "${CubitHome.get(context).modelProfile!.name} : $message",
        "image": image,
        "sounde": "default",
      },
      "data": {
        "phonenumber": id,
        "icon": imagegroup,
        'id': 4,
        "idgroup": idgroup,
        "clicke_action": "FLUTTER_NOTIFICATION_CLICKE",
      }
    });
  }
}

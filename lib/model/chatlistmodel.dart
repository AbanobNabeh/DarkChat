import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListModel {
  String? name;
  String? imageuser;
  String? lastmessage;
  bool? seen;
  String? datatime;
  String? phonenumber;
  String? messageimage;
  String? recored;
  String? document;
  ChatListModel({
    this.name,
    this.imageuser,
    this.lastmessage,
    this.seen,
    this.datatime,
    this.phonenumber,
    this.document,
    this.messageimage,
    this.recored,
  });

  ChatListModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageuser = json['imageuser'];
    lastmessage = json['lastmessage'];
    seen = json['seen'];
    datatime = json['datatime'];
    phonenumber = json['phonenumber'];
    messageimage = json['messageimage'];
    recored = json['recored'];
    document = json['document'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['imageuser'] = this.imageuser;
    data['lastmessage'] = this.lastmessage;
    data['seen'] = this.seen;
    data['datatime'] = this.datatime;
    data['phonenumber'] = this.phonenumber;
    data['document'] = this.document;
    data['recored'] = this.recored;
    data['messageimage'] = this.messageimage;
    return data;
  }
}

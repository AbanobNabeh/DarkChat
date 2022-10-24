class MessageModel {
  String? message;
  String? datetime;
  String? idsender;
  String? idreceived;
  String? messageimage;
  String? messagerecord;
  bool? seen;
  String? idmessage;
  Map? replay;
  DocumentModel? document;
  MessageModel(
      {this.message,
      this.datetime,
      this.idsender,
      this.idreceived,
      this.messageimage,
      this.messagerecord,
      this.seen,
      this.document,
      this.replay,
      this.idmessage});

  MessageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    datetime = json['datetime'];
    idsender = json['idsender'];
    idreceived = json['idreceived'];
    messageimage = json['messageimage'];
    seen = json['seen'];
    messagerecord = json['messagerecord'];
    idmessage = json['idmessage'];
    replay = json['replay'];
    document = json['document'] != null
        ? DocumentModel.fromJson(json['document'])
        : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['datetime'] = this.datetime;
    data['idsender'] = this.idsender;
    data['idreceived'] = this.idreceived;
    data['messageimage'] = this.messageimage;
    data['seen'] = this.seen;
    data['messagerecord'] = this.messagerecord;
    data['replay'] = this.replay;
    data['idmessage'] = this.idmessage;
    if (this.document != null) {
      data['document'] = this.document!.toMap();
    }
    return data;
  }

  indexWhere(Function(dynamic item) param0) {}
}

class DocumentModel {
  String? link;
  String? name;
  int? bytes;

  DocumentModel({this.link, this.name, this.bytes});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    name = json['name'];
    bytes = json['bytes'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    data['name'] = this.name;
    data['bytes'] = this.bytes;
    return data;
  }
}

class MessageGroupModel {
  String? message;
  String? idsender;
  String? imagesender;
  String? namesender;
  String? messageimage;
  String? messagerecord;
  Map? document;
  List? seen;
  String? time;
  String? id;
  Map? replay;
  MessageGroupModel(
      {this.message,
      this.idsender,
      this.imagesender,
      this.namesender,
      this.messageimage,
      this.messagerecord,
      this.document,
      this.seen,
      this.time,
      this.id,
      this.replay});

  MessageGroupModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    idsender = json['idsender'];
    imagesender = json['imagesender'];
    namesender = json['namesender'];
    messageimage = json['messageimage'];
    messagerecord = json['messagerecord'];
    document = json['document'];
    seen = json['seen'];
    time = json['time'];
    id = json['id'];
    replay = json['replay'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['idsender'] = this.idsender;
    data['imagesender'] = this.imagesender;
    data['namesender'] = this.namesender;
    data['messageimage'] = this.messageimage;
    data['messagerecord'] = this.messagerecord;
    data['seen'] = this.seen;
    data['document'] = this.document;
    data['time'] = this.time;
    data['id'] = this.id;
    data['replay'] = this.replay;
    return data;
  }
}

class ModelGroupList {
  String? name;
  String? lastmessage;
  String? image;
  String? time;
  String? createdby;
  String? id;
  String? topic;
  String? messageimage;
  String? messagerecord;
  String? document;
  List? seen;
  ModelGroupList(
      {this.name,
      this.lastmessage,
      this.image,
      this.time,
      this.createdby,
      this.id,
      this.topic,
      this.document,
      this.messageimage,
      this.messagerecord,
      this.seen});

  ModelGroupList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lastmessage = json['lastmessage'];
    image = json['image'];
    time = json['time'];
    createdby = json['createdby'];
    id = json['id'];
    topic = json['topic'];
    document = json['document'];
    messageimage = json['messageimage'];
    messagerecord = json['messagerecord'];
    seen = json['seen'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['lastmessage'] = this.lastmessage;
    data['image'] = this.image;
    data['time'] = this.time;
    data['createdby'] = this.createdby;
    data['id'] = this.id;
    data['topic'] = this.topic;
    data['document'] = this.document;
    data['messageimage'] = this.messageimage;
    data['messagerecord'] = this.messagerecord;
    data['seen'] = this.seen;
    return data;
  }
}

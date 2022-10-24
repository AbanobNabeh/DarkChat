class ModelGroup {
  String? name;
  String? description;
  String? image;
  String? createdby;
  String? datecreategroup;
  String? date;
  String? canadd;
  String? cansendmessage;
  String? lastmessage;
  String? topic;
  String? id;
  String? time;
  List<Map>? members;
  List? seen;
  ModelGroup(
      {this.name,
      this.description,
      this.image,
      this.createdby,
      this.date,
      this.datecreategroup,
      this.canadd,
      this.cansendmessage,
      this.lastmessage,
      this.id,
      this.topic,
      this.members,
      this.time,
      this.seen});

  ModelGroup.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    image = json['image'];
    createdby = json['createdby'];
    date = json['date'];
    datecreategroup = json['datecreategroup'];
    canadd = json['canadd'];
    cansendmessage = json['cansendmessage'];
    lastmessage = json['lastmessage'];
    topic = json['topic'];
    id = json['id'];
    members = json['members'];
    time = json['time'];
    seen = json['seen'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['createdby'] = this.createdby;
    data['date'] = this.date;
    data['datecreategroup'] = this.datecreategroup;
    data['canadd'] = this.canadd;
    data['cansendmessage'] = this.cansendmessage;
    data['lastmessage'] = this.lastmessage;
    data['topic'] = this.topic;
    data['id'] = this.id;
    data['members'] = this.members;
    data['time'] = this.time;
    data['seen'] = this.seen;
    return data;
  }
}

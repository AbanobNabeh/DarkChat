class ModelProfile {
  String? name;
  String? email;
  String? phonenumber;
  String? bio;
  String? state;
  String? uid;
  bool? private;
  String? date;
  bool? sarahah;
  String? image;
  String? token;
  List<String>? block;
  List<String>? searchcase;
  ModelProfile(
      {this.name,
      this.email,
      this.phonenumber,
      this.bio,
      this.state,
      this.uid,
      this.private,
      this.date,
      this.sarahah,
      this.token,
      this.image,
      this.block,
      this.searchcase});

  ModelProfile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phonenumber = json['phonenumber'];
    bio = json['bio'];
    state = json['state'];
    uid = json['uid'];
    private = json['private'];
    date = json['date'];
    sarahah = json['sarahah'];
    image = json['image'];
    token = json['token'];
    block = json['block'].cast<String>();
    searchcase = json['searchcase'].cast<String>();
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phonenumber'] = this.phonenumber;
    data['bio'] = this.bio;
    data['state'] = this.state;
    data['uid'] = this.uid;
    data['private'] = this.private;
    data['date'] = this.date;
    data['sarahah'] = this.sarahah;
    data['image'] = this.image;
    data['token'] = this.token;
    data['searchcase'] = this.searchcase;
    data['block'] = this.block;
    return data;
  }
}

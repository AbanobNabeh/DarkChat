import 'dart:ffi';

class UserModel {
  String? name;
  String? bio;
  String? image;
  String? state;
  String? phonenumber;
  bool? sarahah;
  String? token;
  List<String>? block;

  UserModel(
      {this.name,
      this.bio,
      this.image,
      this.phonenumber,
      this.token,
      this.state,
      this.sarahah,
      this.block});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    bio = json['bio'];
    image = json['image'];
    state = json['state'];
    phonenumber = json['phonenumber'];
    token = json['token'];
    sarahah = json['sarahah'];
    block = json['block'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['bio'] = this.bio;
    data['image'] = this.image;
    data['state'] = this.state;
    data['phonenumber'] = this.phonenumber;
    data['token'] = this.token;
    data['sarahah'] = this.sarahah;
    data['block'] = this.block;
    return data;
  }
}

class SarahahModel {
  String? message;
  String? datetime;
  String? id;
  String? idsender;
  bool? seen;
  CommentModel? comment;
  String? idreceived;
  String? image;
  SarahahModel(
      {this.message,
      this.datetime,
      this.id,
      this.idsender,
      this.seen,
      this.comment,
      this.idreceived,
      this.image});

  SarahahModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    datetime = json['datetime'];
    id = json['id'];
    idsender = json['idsender'];
    seen = json['seen'];
    comment = json['comment'] != null
        ? new CommentModel.fromJson(json['comment'])
        : null;
    idreceived = json['idreceived'];
    image = json['image'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['datetime'] = this.datetime;
    data['id'] = this.id;
    data['idsender'] = this.idsender;
    data['seen'] = this.seen;
    if (this.comment != null) {
      data['comment'] = this.comment!.toMap();
    }
    data['idreceived'] = this.idreceived;
    data['image'] = this.image;
    return data;
  }
}

class CommentModel {
  String? comment;
  String? datetime;

  String? image;
  CommentModel({this.comment, this.datetime, this.image});

  CommentModel.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    datetime = json['datetime'];
    image = json['image'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment'] = this.comment;
    data['datetime'] = this.datetime;
    data['image'] = this.image;
    return data;
  }
}

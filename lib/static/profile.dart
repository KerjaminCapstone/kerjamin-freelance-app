import 'dart:ffi';

class Profile {
  String? nama;
  String? email;
  String? idUserNik;
  String? nlpTag1;
  String? nlpTag2;
  String? nlpTag3;
  String? nlpTag4;
  String? nlpTag5;
  String? keahlian;
  int? points;
  String? alamat;

  Profile(
    this.nama,
    this.email,
    this.idUserNik,
    this.nlpTag1,
    this.nlpTag2,
    this.nlpTag3,
    this.nlpTag4,
    this.nlpTag5,
    this.keahlian,
    this.points,
    this.alamat,
  ) {}
}

// ignore_for_file: file_names

class KorisnikModel {
  final String id;
  final String email;
  //final String password;
  final bool isAdmin;

  KorisnikModel({
    required this.id,
    required this.email,
    //required this.password,
    required this.isAdmin,
  });

  factory KorisnikModel.fromJson(Map<String, dynamic> json, String id) {
    return KorisnikModel(
      id: id,
      email: json['email'] as String,
      //password: json['password'] as String,
      isAdmin: json['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      //'password': password,
      'isAdmin': isAdmin,
    };
  }



}

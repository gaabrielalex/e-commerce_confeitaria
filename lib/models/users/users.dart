import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? userName;
  String? email;
  String? password;
  String? cpf;
  String? gender;
  DateTime? birthday;
  String? phone;
  bool? isAdmin;

  Users({
    this.id,
    this.userName,
    this.email,
    this.password,
    this.cpf,
    this.gender,
    this.birthday,
    this.phone,
    this.isAdmin = false,
  });

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": userName,
      "email": email,
      "password": password,
      "cpf": cpf,
      "gender": gender,
      "birthday": birthday,
      "phone": phone,
      "isAdmin": isAdmin,
    };
  }

  //Método para converter o documento em um objeto
  Users.fromJson(DocumentSnapshot document) {
    id = document.id;
    userName = document.get('username');
    email = document.get('email');
    password = document.get('password');
    cpf = document.get('cpf');
    gender = document.get('gender');
    // ignore: prefer_null_aware_operators
    birthday = document.get('birthday') != null 
        ? document.get('birthday').toDate()
        : null;
    phone = document.get('phone');
    isAdmin = document.get('isAdmin');
  } 
}

enum Genders {
  masculine('Masculino'),
  feminine('Feminino'),
  others('Outros'),
  dontSay( 'Prefiro não dizer');

  final String _text;

  const Genders(this._text);

  String get text => _text;

  static List<String> getGendersList() {
    return Genders.values.map((gender) => gender._text).toList();
  } 
}

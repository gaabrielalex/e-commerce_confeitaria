import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String? id;
  DocumentReference? addressRef;
  DocumentReference? userRef;
  String? addressIdentification;
  String? recipient;
  String? zipCode;
  String? address;
  String? number;
  String? complement;
  String? neighborhood;
  String? city;
  String? state;
  String? reference;

  Address({
    this.id,
    this.userRef,
    this.addressIdentification,
    this.recipient,
    this.zipCode,
    this.address,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.reference,
  });

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "userRef": userRef,
      "addressIdentification": addressIdentification,
      "recipient": recipient,
      "zipCode": zipCode,
      "address": address,
      "number": number,
      "complement": complement,
      "neighborhood": neighborhood,
      "city": city,
      "state": state,
      "reference": reference,
    };
  }

  //Método para converter o documento em um objeto
  Address.fromJson(DocumentSnapshot document) {
    id = document.id;
    addressRef = document.reference;
    userRef = document.get('userRef');
    addressIdentification = document.get('addressIdentification');
    recipient = document.get('recipient');
    zipCode = document.get('zipCode');
    address = document.get('address');
    number = document.get('number');
    complement = document.get('complement');
    neighborhood = document.get('neighborhood');
    city = document.get('city');
    state = document.get('state');
    reference = document.get('reference');
  }
}

enum States {
  ac('Acre'),
  al('Alagoas'),
  ap('Amapá'),
  am('Amazonas'),
  ba('Bahia'),
  ce('Ceará'),
  df('Distrito Federal'),
  es('Espírito Santo'),
  go('Goiás'),
  ma('Maranhão'),
  mt('Mato Grosso'),
  ms('Mato Grosso do Sul'),
  mg('Minas Gerais'),
  pa('Pará'),
  pb('Paraíba'),
  pr('Paraná'),
  pe('Pernambuco'),
  pi('Piauí'),
  rj('Rio de Janeiro'),
  rn('Rio Grande do Norte'),
  rs('Rio Grande do Sul'),
  ro('Rondônia'),
  rr('Roraima'),
  sc('Santa Catarina'),
  sp('São Paulo'),
  se('Sergipe'),
  to('Tocantins');

  final String _text;

  const States(this._text);

  String get text => _text;

  static List<String> getStatesList() {
    return States.values.map((states) => states._text).toList();
  }

  static String? stateToAcronym(String state) {
    switch (state) {
      case 'Acre':
        return 'AC';
      case 'Alagoas':
        return 'AL';
      case 'Amapá':
        return 'AP';
      case 'Amazonas':
        return 'AM';
      case 'Bahia':
        return 'BA';
      case 'Ceará':
        return 'CE';
      case 'Distrito Federal':
        return 'DF';
      case 'Espírito Santo':
        return 'ES';
      case 'Goiás':
        return 'GO';
      case 'Maranhão':
        return 'MA';
      case 'Mato Grosso':
        return 'MT';
      case 'Mato Grosso do Sul':
        return 'MS';
      case 'Minas Gerais':
        return 'MG';
      case 'Pará':
        return 'PA';
      case 'Paraíba':
        return 'PB';
      case 'Paraná':
        return 'PR';
      case 'Pernambuco':
        return 'PE';
      case 'Piauí':
        return 'PI';
      case 'Rio de Janeiro':
        return 'RJ';
      case 'Rio Grande do Norte':
        return 'RN';
      case 'Rio Grande do Sul':
        return 'RS';
      case 'Rondônia':
        return 'RO';
      case 'Roraima':
        return 'RR';
      case 'Santa Catarina':
        return 'SC';
      case 'São Paulo':
        return 'SP';
      case 'Sergipe':
        return 'SE';
      case 'Tocantins':
        return 'TO';
      default:
        return null;
    }
  }
}

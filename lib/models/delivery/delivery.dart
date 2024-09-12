import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/address/address.dart';

class Delivery {
  String? id;
  DocumentReference? addressRef;
  Address? address;
  DeliveryCategories? deliveryCategory;
  String? recipientNanme;
  String? observations;
  DateTime? deliveryDate;
  double? deliveryPrice;

  Delivery({
    this.id,
    this.addressRef,
    this.address,
    this.deliveryCategory,
    this.recipientNanme,
    this.observations,
    this.deliveryDate,
    this.deliveryPrice = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      "addressRef": addressRef,
      "deliveryCategory": deliveryCategory?.name,
      "recipientNanme": recipientNanme,
      "observations": observations,
      "deliveryDate": deliveryDate,
      "deliveryPrice": deliveryPrice,
    };
  }

  Delivery.fromJson(DocumentSnapshot? document) {
    if (document == null) {
      return;
    }
    id = document.id;
    addressRef = document.get('addressRef');
    deliveryCategory = document.get('deliveryCategory');
    recipientNanme = document.get('recipientNanme');
    observations = document.get('observations');
    deliveryDate = document.get('deliveryDate')?.toDate();
    deliveryPrice = (document.get('deliveryPrice') as num?)?.toDouble() ?? 0.0;
  }

  Delivery.fromMap(Map<String, dynamic> map) {
    deliveryCategory = DeliveryCategories.values
        .firstWhere((e) => e.name == map['deliveryCategory']);
    recipientNanme = map['recipientNanme'];
    observations = map['observations'];
    deliveryDate = map['deliveryDate']?.toDate();
    deliveryPrice = (map['deliveryPrice'] as num?)?.toDouble();
  }
}

enum DeliveryCategories {
  delivery("Entrega"),
  withDraw("Retirar na loja");

  final String _name;

  const DeliveryCategories(this._name);

  String get name => _name;

  static List<String> getNames() {
    return DeliveryCategories.values.map((e) => e._name).toList();
  }
}

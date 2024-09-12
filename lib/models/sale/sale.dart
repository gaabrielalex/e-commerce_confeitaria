

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/delivery/delivery.dart';
import 'package:confeitaria_divine_cacau/models/payment/payment.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale_item.dart';

class Sale {
  String? id;
  DocumentReference? userRef;
  DateTime? createdAt;
  SaleStatus? status;
  List<SaleItem>? items;
  double? subTotal;
  double? total;
  Delivery? delivery;
  Payment? payment;

  Sale({
    this.id,
    this.userRef,
    this.createdAt,
    this.status,
    this.items,
    this.subTotal,
    this.delivery,
    this.payment,
  }) {
    total = subTotal! + delivery!.deliveryPrice!;
    createdAt = createdAt ?? DateTime.now();
  }

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "userRef": userRef,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
      "status": status?.name,
      "items": items!.map((item) => item.toJson()).toList(),
      "subTotal": subTotal,
      "total": total,
      "delivery": delivery!.toJson(),
      "payment": payment!.toJson(),
    };
  }

  //Método para converter o documento em um objeto
  Sale.fromJson(DocumentSnapshot document) {
    id = document.id;
    userRef = document.get('userRef');
    createdAt = document.get('createdAt').toDate();
    status = SaleStatus.fromString(document.get('status'));
    items = (document.get('items') as List).map((item) => SaleItem.fromMap(item)).toList();
    subTotal = document.get('subTotal');
    total = document.get('total');
    delivery = Delivery.fromMap(document.get('delivery'));
    payment = Payment.fromMap(document.get('payment'));
  }
}

enum SaleStatus { 
  pending("Pendente"),
  processing("Processando"),
  delivered("Entregue"),
  canceled("Cancelado");

  final String _name;

  const SaleStatus(this._name);

  String get name => _name;

  static SaleStatus? fromString(String? name) {
    return SaleStatus.values.firstWhere((element) => element.name == name);
  }
}
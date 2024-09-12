import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale.dart';
import 'package:flutter/material.dart';

class SaleService {
  final CollectionReference<Map<String, dynamic>> _saleCollectionRef =
      FirebaseFirestore.instance.collection('sales');

  Future<bool> addSale(Sale sale) async {
    try {
      await _saleCollectionRef.add(sale.toJson());
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Stream<QuerySnapshot>? getAllSalesStreamByUser(DocumentReference userRef) {
    try {
      return _saleCollectionRef
          .where('userRef', isEqualTo: userRef)
          .snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}

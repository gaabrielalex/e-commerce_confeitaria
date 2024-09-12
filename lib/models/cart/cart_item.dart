import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart'; 

class CartItem {
  String? id;
  DocumentReference? userRef;
  DocumentReference? productRef;
  Product? product;
  int? quantity;

  CartItem({
    this.id,
    this.userRef,
    this.productRef,
    this.product,
    this.quantity,
  });

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "userRef": userRef,
      "productRef": productRef,
      "quantity": quantity,
    };
  }

  //Método para converter o documento em um objeto
  CartItem.fromJson(DocumentSnapshot document) {
    id = document.id;
    userRef = document.get('userRef');
    productRef = document.get('productRef');
    // product = Product.fromJson(document.get('productRef').get());
    quantity = document.get('quantity');
  }
}

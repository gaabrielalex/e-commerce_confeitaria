
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_item.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';

class SaleItem {
  String? id;
  Product? product;
  int? quantity;

  SaleItem({
    this.id,
    this.product,
    this.quantity,
  });

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "product": product!.toJson(),
      "quantity": quantity,
    };
  }

  //Método para converter o documento em um objeto
  SaleItem.fromJson(DocumentSnapshot document) {
    id = document.id;
    product = Product.fromJson(document.get('product').get());
    quantity = document.get('quantity');
  }

  SaleItem.fromMap(Map<String, dynamic> map) {
    product = Product.fromMap(map['product']);
    quantity = map['quantity'];
  }

  SaleItem.fromCartItem(CartItem cartItem) {
    product = cartItem.product;
    quantity = cartItem.quantity;
  }

}
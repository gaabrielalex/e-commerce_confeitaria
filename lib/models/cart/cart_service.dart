import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_item.dart';
import 'package:confeitaria_divine_cacau/models/delivery/delivery.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  static const String _cartItemcollectionName = 'item';
  final CollectionReference<Map<String, dynamic>> _cartCollectionRef =
      FirebaseFirestore.instance.collection('cart');
  // final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<CartItem> cartItems = [];
  String? userRef;
  Delivery? delivery;

  CartService(DocumentReference? userRef) {
    if (userRef != null) {
      this.userRef = userRef.id;
      getAllCartItems(userRef).then((value) {
        cartItems = value;
        notifyListeners();
      });
    }
  }

  get subTotal => getSubTotalPrice(cartItems);

  get totalPrice => subTotal + delivery!.deliveryPrice!;

  refreshCart(DocumentReference userRef) {
    getAllCartItems(userRef).then((value) {
      cartItems = value;
      notifyListeners();
    });
  }

  Future<List<CartItem>> getAllCartItems(DocumentReference userRef) async {
    try {
      List<CartItem> cartItemList = [];
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _cartCollectionRef
              .doc(userRef.id)
              .collection(_cartItemcollectionName)
              .get();
      for (var element in querySnapshot.docs) {
        CartItem cartItem = CartItem.fromJson(element);
        cartItemList.add(cartItem);
      }
      for (var cartItem in cartItemList) {
        cartItem.product = Product.fromJson(await cartItem.productRef!.get());
      }
      return cartItemList;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Stream<QuerySnapshot>? getAllCartItemsStream(DocumentReference userRef) {
    try {
      return _cartCollectionRef
          .doc(userRef.id)
          .collection(_cartItemcollectionName)
          .snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> addCartItem(DocumentReference userRef, CartItem cartItem) async {
    try {
      DocumentSnapshot? doc;
      try {
        doc = await _cartCollectionRef
            .doc(userRef.id)
            .collection(_cartItemcollectionName)
            .get()
            .then((value) => value.docs.firstWhere(
                (element) => element.get('productRef') == cartItem.productRef));
      } catch (e) {
        debugPrint(e.toString());
      }
      if (doc != null && doc.exists) {
        DocumentSnapshot cartItemDoc = await _cartCollectionRef
            .doc(userRef.id)
            .collection(_cartItemcollectionName)
            .doc(doc.id)
            .get();
        CartItem oldCartItem = CartItem.fromJson(cartItemDoc);
        cartItem.quantity = oldCartItem.quantity! + cartItem.quantity!;

        await _cartCollectionRef
            .doc(userRef.id)
            .collection(_cartItemcollectionName)
            .doc(doc.id)
            .update(cartItem.toJson());
      } else {
        await _cartCollectionRef
            .doc(userRef.id)
            .collection(_cartItemcollectionName)
            .add(cartItem.toJson());
      }
      /*É necessário atualizar a lista de itens do carrinho apenas por que o widget que
      indica a quantidade de itens de um determinado produto no carrinho não é atualizado 
      automaticamente pelo stream igual a outros componentes da tela.*/
      refreshCart(userRef);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateCartItem(
      DocumentReference userRef, CartItem cartItem) async {
    try {
      await _cartCollectionRef
          .doc(userRef.id)
          .collection(_cartItemcollectionName)
          .doc(cartItem.id)
          .update(cartItem.toJson());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> removeCartItem(DocumentReference userRef, String? id) async {
    try {
      await _cartCollectionRef
          .doc(userRef.id)
          .collection(_cartItemcollectionName)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static double getSubTotalPrice(List<CartItem> cartItems) {
    double total = 0;
    for (var element in cartItems) {
      total += element.product!.unitPrice! * element.quantity!;
    }
    return total;
  }

  Future<void> _clearCart(DocumentReference userRef) async {
    try {
      for (var cartItem in cartItems) {
        await removeCartItem(userRef, cartItem.id);
      }
      // await FirebaseFirestore.instance.runTransaction((transaction) async {
      //   transaction.delete(_cartCollectionRef.doc(userRef.id));
      // });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearCart() async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userRef);
    await _clearCart(userDocRef);
    cartItems = [];
    notifyListeners();
  }
}

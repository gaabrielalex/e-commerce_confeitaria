import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:flutter/material.dart';

class AddressService extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> _addressesCollectionRef = FirebaseFirestore.instance.collection('addresses');

  Stream<QuerySnapshot>? getAllAddressesStream(DocumentReference userRef) {
    try {
      return _addressesCollectionRef
          .where('userRef', isEqualTo: userRef)
          .snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<DocumentSnapshot>>? getAllAddresses(DocumentReference<Object?> currentUsersDocRef) {
    try {
      return _addressesCollectionRef
          .where('userRef', isEqualTo: currentUsersDocRef)
          .get()
          .then((value) => value.docs);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Stream<DocumentSnapshot>? getAddressStreamById(String addressId) {
    try {
      return _addressesCollectionRef.doc(addressId).snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<DocumentSnapshot>? getAddressById(String addressId) {
    try {
      return _addressesCollectionRef.doc(addressId).get();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
  
  Future<bool> addAddress(Address address) async {
    try {
      await _addressesCollectionRef.add(address.toJson());
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future<bool> updateAddress(String addressId, Address address) async {
    try {
      await _addressesCollectionRef.doc(addressId).update(address.toJson());
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _addressesCollectionRef.doc(addressId).delete();
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  //Verifica se o o usuário atingiu o limite de endereços cadastrados
  Future<bool> hasReachedAddressesLimit(DocumentReference userRef) async {
    final addressesRef = _addressesCollectionRef.where('userRef', isEqualTo: userRef);
    final querySnapshot = await addressesRef.get();

    return Future.value(querySnapshot.docs.length >= 10);
  }

  /* --- Validações --- */
  static String? validateZipCode(String? zipCode) {
    String? deformattedZipCode = zipCode!.replaceAll(RegExp(r'[^0-9]'), '');
    return ViewUtils.validateRequiredField(zipCode) ??
        (deformattedZipCode.length != 8 ? 'CEP inválido.' : null); 
  }

}

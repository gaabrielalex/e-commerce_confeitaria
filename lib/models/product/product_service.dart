import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  final CollectionReference<Map<String, dynamic>> _productsCollectionRef =
      FirebaseFirestore.instance.collection('products');
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //O firebase não suporte esse tipo de filtro
  List<Product> filterByDescription(List<Product> products, String query) {
    return products
        .where((element) =>
            element.description!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<DocumentSnapshot?> getProductById(String? productId) async {
    if (productId == null || productId.isEmpty) {
      return Future.value(null);
    }
    try {
      return await _productsCollectionRef.doc(productId).get();
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(null);
    }
  }

  Stream<QuerySnapshot>? getAllProductsStream(String? category,
      String? typesChocolate, double? minPrice, double? maxPrice) {
    //Não consegui aplicar os filtros sobre preço no firebase
    minPrice ??= 0;
    maxPrice ??= 1000000;
    try {
      if (category == null && typesChocolate == null) {
        return _productsCollectionRef
            .where('deleted', isEqualTo: false)
            .where('imageUrl', isNull: false)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else if (category != null && typesChocolate == null) {
        return _productsCollectionRef
            .where('deleted', isEqualTo: false)
            .where('imageUrl', isNull: false)
            .where('category', isEqualTo: category)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else if (category == null && typesChocolate != null) {
        return _productsCollectionRef
            .where('deleted', isEqualTo: false)
            .where('imageUrl', isNull: false)
            .where('typeChocolate', isEqualTo: typesChocolate)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else {
        return _productsCollectionRef
            .where('deleted', isEqualTo: false)
            .where('imageUrl', isNull: false)
            .where('category', isEqualTo: category)
            .where('typeChocolate', isEqualTo: typesChocolate)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      }
      /* --- Firebase não me deixa ordernar primeiramente por "description" e depois por "imageUrl --- */
      // .orderBy('imageUrl', descending: false)
      // .orderBy('description', descending: false)
      /* --- Não consegui fazer o filtro abaixo funcionar --- */
      // .where(
      //   Filter.or(
      //     Filter('quantityInStock', isGreaterThan: 0),
      //     Filter('onDemand', isEqualTo: true)
      //   )
      // )
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /* Produtos que não estão disponíveis para venda são exibidos apenas para o administrador, assim
  como outras há outras restrições de exibição de produtos para o usuário comum, que, no caso 
  dessa consulta, são ignoradas para que o administrador possa visualizar todos os produtos */
  Stream<QuerySnapshot>? getAllProductsStreamWhitoutRestrictions(
      String? category, String? typesChocolate) {
    try {
      if (category == null && typesChocolate == null) {
        return _productsCollectionRef
            .orderBy('description', descending: false)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else if (category != null && typesChocolate == null) {
        return _productsCollectionRef
            .where('category', isEqualTo: category)
            .orderBy('description', descending: false)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else if (category == null && typesChocolate != null) {
        return _productsCollectionRef
            .where('typeChocolate', isEqualTo: typesChocolate)
            .orderBy('description', descending: false)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      } else {
        return _productsCollectionRef
            .where('category', isEqualTo: category)
            .where('typeChocolate', isEqualTo: typesChocolate)
            .orderBy('description', descending: false)
            .snapshots()
            .handleError((e) {
          debugPrint(e.toString());
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Stream<DocumentSnapshot>? getProductStreamById(String? productId) {
    if (productId == null || productId.isEmpty) {
      return null;
    }
    try {
      return _productsCollectionRef.doc(productId).snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<DocumentSnapshot>? getAddressById(String addressId) {
    try {
      return _productsCollectionRef.doc(addressId).get();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<DocumentReference?> getProductRefById(String? productId) async {
    if (productId == null || productId.isEmpty) {
      return Future.value(null);
    }
    try {
      return _productsCollectionRef.doc(productId);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(null);
    }
  }

  Future<bool> addProduct({
    required Product product,
    dynamic imageFile,
    bool platIsWeb = false,
  }) async {
    try {
      var productDocumment = await _productsCollectionRef.add(product.toJson());
      if (imageFile != null) {
        final lastUserToUpdate = await product.lastUserToUpdate!.get();
        await _uploadImage(lastUserToUpdate.get('username'),
            productDocumment.id, imageFile, platIsWeb);
      }
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required Product product,
    dynamic imageFile,
    bool platIsWeb = false,
  }) async {
    try {
      await _productsCollectionRef.doc(productId).update(product.toJson());
      if (imageFile != null) {
        final lastUserToUpdate = await product.lastUserToUpdate!.get();
        await _uploadImage(
            lastUserToUpdate.get('username'), productId, imageFile, platIsWeb);
      }
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  Future<bool> disableProduct(String productId, bool disable) async {
    try {
      await _productsCollectionRef.doc(productId).update({'deleted': disable});
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  _uploadImage(String? uploadedBy, String? productId, dynamic imageFile,
      bool platIsWeb) async {
    //Cria uma chave única para o nome da imagem
    final uuid = const Uuid().v1();
    SettableMetadata settableMetadata = SettableMetadata(
      contentType: 'image/jpg',
      customMetadata: {
        'Uploaded by': uploadedBy ?? 'Anônimo',
        // 'imageName': imageFile.name,
      },
    );

    try {
      Reference storageRef = _firebaseStorage
          .ref()
          .child('products')
          .child(productId ?? 'product')
          .child(uuid);
      //Objeto para persistir a imagem no firebasestorage
      UploadTask task; //
      if (!platIsWeb) {
        task = storageRef.putFile(
          imageFile,
          settableMetadata,
        );
      } else {
        task = storageRef.putData(
          imageFile,
          settableMetadata,
        );
      }
      //Executa a tarefa de upload já obtendo a url da imagem para persistir no firestore
      String url = await (await task.whenComplete(() {})).ref.getDownloadURL();
      await _productsCollectionRef.doc(productId).update({'imageUrl': url});
    } on FirebaseException catch (e) {
      if (e.code != 'OK') {
        debugPrint('Problemas ao gravar dados');
      } else if (e.code == 'ABORTED') {
        debugPrint('Inclusão de dados abortada');
      }
      return Future.value(false);
    }
  }
}

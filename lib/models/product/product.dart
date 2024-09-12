
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  DocumentReference? lastUserToUpdate;
  String? description;
  String? category;
  String? typeChocolate;
  double? unitPrice;
  int? quantityInStock;
  bool? onDemand; 
  String? imageUrl;
  bool? deleted;

  Product({
    this.id,
    this.lastUserToUpdate,
    this.description,
    this.category,
    this.typeChocolate,
    this.unitPrice,
    this.quantityInStock,
    this.onDemand = true,
    this.imageUrl,
    this.deleted = false,
  });

  //Método para converter o objeto em um documento
  Map<String, dynamic> toJson() {
    return {
      "lastUserToUpdate": lastUserToUpdate,
      "description": description,
      "category": category,
      "typeChocolate": typeChocolate,
      "unitPrice": unitPrice,
      "quantityInStock": quantityInStock,
      "onDemand": onDemand,
      "imageUrl": imageUrl,
      "deleted": deleted,
    };
  }

  //Método para converter o documento em um objeto
  Product.fromJson(DocumentSnapshot? document) {
    if (document == null) {
      return;
    }
    id = document.id;
    lastUserToUpdate = document.get('lastUserToUpdate');
    description = document.get('description');
    category = document.get('category');
    typeChocolate = document.get('typeChocolate');
    unitPrice = (document.get('unitPrice') as num?)?.toDouble() ?? 0.0;
    quantityInStock = document.get('quantityInStock');
    onDemand = document.get('onDemand');
    imageUrl = document.get('imageUrl');
    deleted = document.get('deleted');
  }

  Product.fromMap(Map<String, dynamic> map) {
    description = map['description'];
    category = map['category'];
    typeChocolate = map['typeChocolate'];
    unitPrice = (map['unitPrice'] as num?)?.toDouble() ?? 0.0;
    quantityInStock = map['quantityInStock'];
    onDemand = map['onDemand'];
    imageUrl = map['imageUrl'];
    deleted = map['deleted'];
  }
}

enum ProductCategories {
  todos("Todos"),
  ovos("Ovos"),
  brigadeirosTrufas("Brigadeiros/Trufas"),
  kitsCestas("Kits/Cestas"),
  datasComemorativas("Datas Comemorativas"),
  formasEspeciais("Formas Especiais"),
  barras("Barras"),
  outros("Outros");

  final String _text;

  const ProductCategories(this._text);

  String get text => _text;

  static List<String> getProductCategoriesList() {
    return ProductCategories.values.map((states) => states._text).toList();
  }
}

enum TypesChocolate {
  todos("Todos"),
  aoLeite("Ao Leite"),
  branco("Branco"),
  amargo("Amargo"),
  meioAmargo("Meio Amargo"),
  mesclado("Mesclado");

  final String _text;

  const TypesChocolate(this._text);

  String get text => _text;

  static List<String> getTypesChocolateList() {
    return TypesChocolate.values.map((states) => states._text).toList();
  }
}

import 'package:badiup/models/stock_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Category {
  apparel,
  coffeeDessert,
  coffeeLiquid,
  misc,
  miscDessert,
}

String getDisplayText(Category category) {
  switch (category) {
    case Category.apparel:
      return "服飾";
    case Category.coffeeDessert:
      return "コーヒー豆使用お菓子";
    case Category.coffeeLiquid:
      return "コーヒー飲料水";
    case Category.misc:
      return "雑貨";
    case Category.miscDessert:
      return "その他お菓子";
    default:
      return "";
  }
}

class Product {
  final String name;
  final String description;
  final double priceInYen;
  final List<String> imageUrls;
  final DateTime created;
  final String documentId;
  final bool isPublished;
  final Category category;
  final Stock stock;

  Product({
    this.name,
    this.description,
    this.priceInYen,
    this.imageUrls,
    this.created,
    this.documentId,
    this.isPublished,
    this.category,
    this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'priceInYen': priceInYen,
      'imageUrls': imageUrls,
      'created': created,
      'isPublished': isPublished,
      'category': category?.index,
      'stock': stock.toMap(),
    };
  }

  Product.fromMap(Map<String, dynamic> map, String documentId)
      : assert(map['name'] != null),
        name = map['name'],
        description = map['description'],
        priceInYen = map['priceInYen'],
        imageUrls = map['imageUrls']?.cast<String>(),
        created = map['created'].toDate(),
        isPublished = map['isPublished'],
        category =
            map['category'] != null ? Category.values[map['category']] : null,
        stock = map['stock'] != null ? Stock.fromMap(map['stock'].cast<String, dynamic>()) : null,
        documentId = documentId;

  Product.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID);
}

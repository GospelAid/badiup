import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String description;
  final double priceInYen;
  final List<String> imageUrls;
  final DateTime created;
  final String documentId;
  final bool isPublished;

  Product({
    this.name, 
    this.description, 
    this.priceInYen,
    this.imageUrls,
    this.created,
    this.documentId,
    this.isPublished,
  });

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'description' : description,
      'priceInYen' : priceInYen,
      'imageUrls' : imageUrls,
      'created' : created,
      'isPublished' : isPublished,
    };
  }

  Product.fromMap(Map<String, dynamic> map, String documentId)
    : assert(map['name'] != null),
      name = map['name'],
      description = map['description'],
      priceInYen = map['priceInYen'],
      imageUrls = map['imageUrls'].cast<String>(),
      created = map['created'].toDate(),
      isPublished = map['isPublished'],
      documentId = documentId; 

  Product.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.documentID);
}

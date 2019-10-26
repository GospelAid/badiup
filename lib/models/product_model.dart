import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String caption;
  final String description;
  final double priceInYen;
  final String imageUrl;
  final DateTime created;
  final String documentId;

  Product({
    this.name, 
    this.caption, 
    this.description, 
    this.priceInYen,
    this.imageUrl,
    this.created,
    this.documentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'caption' : caption,
      'description' : description,
      'priceInYen' : priceInYen,
      'imageUrl' : imageUrl,
      'created' : created,
    };
  }

  Product.fromMap(Map<String, dynamic> map, String documentId)
    : assert(map['name'] != null),
      name = map['name'],
      caption = map['caption'],
      description = map['description'],
      priceInYen = map['priceInYen'],
      imageUrl = map['imageUrl'],
      created = map['created'].toDate(),
      documentId = documentId; 

  Product.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, snapshot.documentID);
}
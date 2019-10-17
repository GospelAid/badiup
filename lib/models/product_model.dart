import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String caption;
  final String description;
  final double priceInYen;

  Product({
    this.name, 
    this.caption, 
    this.description, 
    this.priceInYen
  });

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'caption' : caption,
      'description' : description,
      'priceInYen' : priceInYen,
    };
  }

  Product.fromMap(Map<String, dynamic> map)
    : assert(map['name'] != null),
      name = map['name'],
      caption = map['caption'],
      description = map['description'],
      priceInYen = map['priceInYen'];

  Product.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data);
}
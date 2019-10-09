import 'package:flutter/material.dart';

class ProductCatalog extends StatefulWidget {
  ProductCatalog({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProductCatalogState createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            semanticLabel: 'menu',
          ),
          onPressed: () => {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'new_product',
            ),
            onPressed: () => {},
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              semanticLabel: 'cart',
            ),
            onPressed: () => {},
          ),
        ],
      ), 
    );
  }
}
import 'package:flutter/material.dart';

import 'package:badiup/models/product_model.dart';

class AdminProductDetailPage extends StatefulWidget {
  AdminProductDetailPage({
    Key key,
    this.product,
  }) : super(
          key: key,
        );

  final Product product;

  @override
  _AdminProductDetailPageState createState() => _AdminProductDetailPageState();
}

class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildProductDetail(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.product.name),
    );
  }

  Widget _buildProductDetail(BuildContext context) {}
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/widgets/product_detail.dart';

class CustomerProductDetailPage extends StatefulWidget {
  CustomerProductDetailPage({
    Key key,
    this.productDocumentId,
  }) : super(key: key);

  final String productDocumentId;

  @override
  _CustomerProductDetailPageState createState() =>
      _CustomerProductDetailPageState();
}

class _CustomerProductDetailPageState extends State<CustomerProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ProductDetail(
        productDocumentId: widget.productDocumentId,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.products)
            .document(widget.productDocumentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("");
          }
          var product = Product.fromSnapshot(snapshot.data);

          return Text(product.name);
        },
      ),
    );
  }
}

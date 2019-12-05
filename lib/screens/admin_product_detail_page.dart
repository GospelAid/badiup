import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/test_keys.dart';
import 'package:badiup/models/product_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/widgets/product_detail.dart';

class AdminProductDetailPage extends StatefulWidget {
  AdminProductDetailPage({
    Key key,
    this.productDocumentId,
  }) : super(key: key);

  final String productDocumentId;

  @override
  _AdminProductDetailPageState createState() => _AdminProductDetailPageState();
}

class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ProductDetail(
        productDocumentId: widget.productDocumentId,
      ),
      floatingActionButton: _buildEditButton(),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.productDetail,
        "edit",
      )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNewProductPage(
              productDocumentId: widget.productDocumentId,
            ),
          ),
        );
      },
      child: _buildEditButtonIcon(),
    );
  }

  Stack _buildEditButtonIcon() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paletteForegroundColor,
          ),
        ),
        Icon(
          Icons.edit,
          color: kPaletteWhite,
          size: 40,
        ),
      ],
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

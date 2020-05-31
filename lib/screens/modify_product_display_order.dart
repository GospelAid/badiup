import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModifyProductDisplayOrderPage extends StatefulWidget {
  @override
  _ModifyProductDisplayOrderPageState createState() =>
      _ModifyProductDisplayOrderPageState();
}

class _ModifyProductDisplayOrderPageState
    extends State<ModifyProductDisplayOrderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  bool formSubmitInProgress = false;

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: formSubmitInProgress ? LinearProgressIndicator() : _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text("公開済み製品リスト"),
      actions: <Widget>[
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "保存",
              style: TextStyle(
                color: kPaletteWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () async {
            await _saveProductOrder();
          },
        ),
      ],
    );
  }

  Future _saveProductOrder() async {
    setState(() {
      formSubmitInProgress = true;
    });

    for (var i = 0; i < productList.length; i++) {
      var productItem = productList[i];
      if (productItem.displayOrder != i) {
        productItem.displayOrder = i;
        await Firestore.instance
            .collection(constants.DBCollections.products)
            .document(productItem.documentId)
            .updateData(productItem.toMap());
      }
    }

    _scaffoldKey.currentState.showSnackBar(
      buildSnackBar("製品の順番の見せ方を変更しました。"),
    );

    setState(() {
      formSubmitInProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection(constants.DBCollections.products)
        .orderBy('displayOrder')
        .getDocuments()
        .then((querySnapshot) {
      setState(() {
        querySnapshot.documents.forEach((doc) {
          var product = Product.fromMap(doc.data, doc.documentID);
          if (product.isPublished) {
            productList.add(product);
          }
        });
      });
    });
  }

  Widget _buildBody() {
    return ReorderableListView(
      scrollDirection: Axis.vertical,
      children: _getProductPaneList(),
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final product = productList.removeAt(oldIndex);
          productList.insert(newIndex, product);
        });
      },
    );
  }

  List<Widget> _getProductPaneList() {
    List<Widget> widgetList = [];
    productList.forEach((product) {
      widgetList.add(Container(
        decoration: BoxDecoration(
          color: kPaletteWhite,
          border: Border(
            top: BorderSide(color: paletteGreyColor3),
            bottom: BorderSide(color: paletteGreyColor3),
          ),
        ),
        key: Key(product.documentId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: <Widget>[
              Icon(Icons.drag_handle, color: paletteDarkGreyColor),
              SizedBox(width: 20),
              Text(
                product.name,
                style: TextStyle(color: paletteBlackColor),
              ),
            ],
          ),
        ),
      ));
    });
    return widgetList;
  }
}

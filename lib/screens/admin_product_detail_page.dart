import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/screens/admin_new_product_page.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/widgets/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.products)
          .document(widget.productDocumentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        var product = Product.fromSnapshot(snapshot.data);

        return Scaffold(
          appBar: _buildAppBar(context),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAdminProductDetailInternal(product),
          ),
          floatingActionButton: _buildEditButton(),
        );
      },
    );
  }

  Widget _buildAdminProductDetailInternal(Product product) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            ProductDetail(
              productDocumentId: widget.productDocumentId,
            ),
            SizedBox(height: 40),
          ]),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildListDelegate(
            _buildStockGridItems(product),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            SizedBox(height: 100),
          ]),
        ),
      ],
    );
  }

  List<Widget> _buildStockGridItems(Product product) {
    List<Widget> _widgetList = [];

    product.stock.items.forEach((stockItem) {
      _widgetList.add(Container(
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          color: product.stock.stockType == StockType.sizeOnly
              ? Colors.transparent
              : getDisplayColorForItemColor(stockItem.color),
          border: product.stock.stockType == StockType.sizeOnly
              ? Border.all(color: paletteGreyColor)
              : null,
        ),
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            _buildStockItemQuantity(stockItem),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildStockItemText(stockItem, product.stock.stockType)
              ],
            ),
          ],
        ),
      ));
    });

    return _widgetList;
  }

  Widget _buildStockItemText(StockItem stockItem, StockType stockType) {
    Color _color = stockType == StockType.sizeOnly
        ? paletteGreyColor2
        : getDisplayTextColorForItemColor(stockItem.color);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          stockType == StockType.colorOnly
              ? Container()
              : Text(
                  getDisplayTextForItemSize(stockItem.size),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
          stockType == StockType.sizeOnly
              ? Container()
              : Text(
                  getDisplayTextForItemColor(stockItem.color),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStockItemQuantity(StockItem stockItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: AlignmentDirectional.center,
          height: 20,
          width: 40,
          color: paletteForegroundColor,
          child: Text(
            "残" + stockItem.quantity.toString(),
            style: TextStyle(
              color: kPaletteWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

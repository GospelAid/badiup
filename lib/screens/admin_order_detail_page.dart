import 'package:badiup/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/order_model.dart';

class AdminOrderDetailPage extends StatefulWidget {
  AdminOrderDetailPage({Key key, this.order}) : super(key: key);

  final Order order;

  @override
  _AdminOrderDetailPageState createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  Map<String, OrderItem> orderItems = Map<String, OrderItem>();

  @override
  Widget build(BuildContext context) {
    widget.order.items.forEach( (item) {
      orderItems[item.productId] = item;
    } );

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.order.orderId,
        style: TextStyle(
          color: paletteBlackColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        )
      ),
      centerTitle: true,
      backgroundColor: paletteLightGreyColor,
      elevation: 0.0,
      iconTheme: IconThemeData(color: paletteBlackColor),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: paletteLightGreyColor,
      child: ListView(
        children: <Widget>[
          _buildOrderPlacedDateText(),
          _buildOrderStatusDescriptionBar(),
          _buildOrderItemBlocks(context),
          _buildOrderPriceDescriptionBar(),
        ],
      ),
    );
  }

  Widget _buildOrderPlacedDateText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only( right: 16.0 ),
          child: Text(
            DateFormat('yyyy.MM.dd').format(widget.order.placedDate) + '受付',
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusDescriptionBar() {
    return Container(
      padding: EdgeInsets.symmetric( vertical: 8.0 ),
      child: Container(
        height: 56,
        color: widget.order.status == 
            OrderStatus.pending ? paletteDarkRedColor: paletteDarkGreyColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.order.getOrderStatusText(),
              style: TextStyle(
                color: kPaletteWhite,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemBlocks(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.products)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          return _buildOrderItemList(context, snapshot.data.documents);
        }
      ),
    ); 
  }

  Widget _buildOrderItemList(BuildContext context, List<DocumentSnapshot> snapshots) {
    return Column(
      children: snapshots.where(
        (snapshot) => orderItems.keys.contains(snapshot.documentID)
      ).map(
        (snapshot) => _buildOrderItemListItem(context, Product.fromSnapshot(snapshot))
      ).toList(),
    );
  }

  Widget _buildOrderItemListItem(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFA2A2A2)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildProductImage(product),
          Container(
            height: 75.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: paletteBlackColor,
                  ),
                ),
                Text(
                  'Mサイズ/ピンク',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: paletteBlackColor,
                  ),
                ),
                Text(
                  "¥${NumberFormat("#,##0").format(orderItems[product.documentId].price)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: paletteBlackColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only( left: 50.0 ),
            height: 85.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        color: kPaletteWhite,
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          orderItems[product.documentId].quantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: paletteBlackColor,
                          ),
                        ),
                      ),
                      Text(
                        ' 点',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: paletteBlackColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    Widget productImage;
    if (product.imageUrls?.isEmpty ?? true) {
      productImage = Image.memory(
        kTransparentImage,
        height: 85,
        width: 85,
      );
    } else {
      productImage = FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        height: 85,
        width: 85,
        placeholder: kTransparentImage,
        image: product.imageUrls.first,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: productImage,
    );
  }

  Widget _buildOrderPriceDescriptionBar() {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16.0 ),
      height: 40.0,
      child: Container(
        color: kPaletteWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                '総合計',
                style: TextStyle(
                  color: paletteBlackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              child: Text(
                "¥${NumberFormat("#,##0").format(widget.order.getOrderPrice())}",
                style: TextStyle(
                  color: paletteDarkRedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

}
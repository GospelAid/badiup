import 'package:badiup/models/customer_model.dart';
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

  @override
  Widget build(BuildContext context) {
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
          _buildOrderItemList(),
          _buildOrderPriceDescriptionBar(),
          SizedBox(height: 60.0),
          _buildBuyerDetails(),
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

  Widget _buildOrderItemList() {
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

          return Column(
            children: widget.order.items.map( (orderItem) {
              DocumentSnapshot productSnapshot = snapshot.data.documents.firstWhere(
                (snapshot) => snapshot.documentID == orderItem.productId
              );
              return _buildOrderItemListRow(
                orderItem, Product.fromSnapshot(productSnapshot)
              );
            }).toList(),
          );
        }
      ),
    ); 
  }

  Widget _buildOrderItemListRow(OrderItem orderItem, Product product) {
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
          _buildOrderItemTextInfo(orderItem, product),
          _buildOrderItemQuantity(orderItem, product),
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

  Widget _buildOrderItemTextInfo(OrderItem orderItem, Product product) {
    return Container(
      height: 75,
      padding: EdgeInsets.only( right: 50.0 ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildProductName(product),
          _buildOrderItemColorSize(orderItem, product),
          _buildOrderItemPrice(orderItem, product),
        ],
      ),
    );
  }

  Widget _buildProductName(Product product) {
    return Container(
      child: Text(
        product.name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemColorSize(OrderItem orderItem, Product product) {
    return Container(
      child: Text(
        // orderItem.color.toString() + '/' + orderItem.size.toString(),
        '?サイズ/なにいろ',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemPrice(OrderItem orderItem, Product product) {
    return Container(
      child: Text(
        "¥${NumberFormat("#,##0").format(orderItem.price)}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: paletteBlackColor,
        ),
      ),
    );
  }

  Widget _buildOrderItemQuantity(OrderItem orderItem, Product product) {
    return Container(
      height: 85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: kPaletteWhite,
                height: 30,
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  orderItem.quantity.toString(),
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
        ],
      ),
    );
  }

  Widget _buildOrderPriceDescriptionBar() {
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 16.0 ),
      height: 40,
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

  Widget _buildBuyerDetails() {
    return Container(
      decoration: BoxDecoration(
        color: kPaletteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: <Widget>[
          _buildGreyBar(),
          _buildBuyerContactInfoBox(),
          _buildShippingAddressInfoBox(),
          _buildShippingMethodInfoBox(),
        ],
      ),
    );
  }

  Widget _buildGreyBar() {
    return Container(
      padding: EdgeInsets.only( top: 24.0 ),
        child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.all( Radius.circular(40) ),
        ),
        height: 8,
        width: 115,
      ),
    );

  }

  Widget _buildBuyerContactInfoBox() {
    return Container(
      padding: EdgeInsets.only(
        top: 12.0, left: 24.0, right: 24.0, bottom: 36.0
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection(constants.DBCollections.users)
            .document(widget.order.customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          Customer buyer = Customer.fromSnapshot(snapshot.data);
          return Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text(
                  "注文者情報",
                  style: TextStyle(
                    fontSize: 18, color: paletteBlackColor, fontWeight: FontWeight.bold,
                  )
                ),
              ),
              SizedBox(height: 24.0),
              _buildBuyerName(buyer),
              SizedBox(height: 12.0),
              _buildBuyerAddress(buyer),
              SizedBox(height: 6.0),
              _buildBuyerPhone(buyer),
              SizedBox(height: 6.0),
              _buildBuyerEmail(buyer),
            ],
          );
        }
      )
    );
  }

  Widget _buildBuyerName(Customer buyer) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            buyer.name,
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w600,
            )
          ),
          Text(
            " 様",
            style: TextStyle(
              fontSize: 16,
              color: paletteBlackColor,
              fontWeight: FontWeight.w300,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerAddress(Customer buyer) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "住所",
            style: TextStyle(
              fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(width: 30.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "〒1580083",
                style: TextStyle(
                  fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                "東京都世田谷区奥沢2-46-13",
                style: TextStyle(
                  fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerPhone(Customer buyer) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only( top: 6.0 ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide( color: Color(0xFFEFEFEF) ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            "連絡先",
            style: TextStyle(
              fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
            )
          ),
          SizedBox(width: 16.0),
          Text(
            "023456789",
            style: TextStyle(
              fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerEmail(Customer buyer) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only( top: 6.0 ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide( color: Color(0xFFEFEFEF) ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            "メール",
            style: TextStyle(
              fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
            )
          ),
          SizedBox(width: 16.0),
          Text(
            buyer.email,
            style: TextStyle(
              fontSize: 16, color: paletteBlackColor, fontWeight: FontWeight.w300,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressInfoBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFA2A2A2)),
          bottom: BorderSide(color: Color(0xFFA2A2A2)),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12.0, left: 24.0, right: 24.0, bottom: 36.0
      ),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "お届け先",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          SizedBox(height: 25.0),
          _buildShippingAddressInfo(),
        ],
      ),
    );
  }

  Widget _buildShippingAddressInfo() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "上記と同じ",
        style: TextStyle(
          fontSize: 16,
          color: paletteBlackColor,
          fontWeight: FontWeight.w300,
        )
      ),
    );
  }

  Widget _buildShippingMethodInfoBox() {
    return Container(
      padding: EdgeInsets.only(
        top: 12.0, left: 24.0, right: 24.0, bottom: 50.0
      ),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "配送方法",
              style: TextStyle(
                fontSize: 18,
                color: paletteBlackColor,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "ゆうパック　通常配送（3~5日程度）",
              style: TextStyle(
                fontSize: 16,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              )
            ),
          ),
        ],
      ),
    );
  }
}
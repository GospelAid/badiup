import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/screens/cart_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  const CartButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CartPage();
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: <Widget>[
            Icon(
              Icons.shopping_cart,
              size: 32,
            ),
            _buildItemCountDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCountDisplay() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paletteForegroundColor,
          ),
        ),
        _buildItemCountText(),
      ],
    );
  }

  Widget _buildItemCountText() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.users)
          .document(currentSignedInUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        var customer = Customer.fromSnapshot(snapshot.data);
        int itemCount = (customer.cart == null)
            ? 0
            : customer.cart.items.fold(0, (a, b) => a + b.quantity);

        return Text(
          itemCount.toString(),
          style: TextStyle(
            color: kPaletteWhite,
            fontSize: 8,
          ),
        );
      },
    );
  }
}

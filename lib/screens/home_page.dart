import 'package:badiup/screens/new_product_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), 
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
      leading: _buildMenuButton(context),
      actions: <Widget>[
        _buildNewProductButton(context),
        _buildCartButton(context),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        semanticLabel: 'menu',
      ),
      onPressed: () => {},
    );
  }

  Widget _buildNewProductButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.add,
        semanticLabel: 'new_product',
      ),
      onPressed: () => {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => NewProductPage()
          ),
        )
      },
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.shopping_cart,
        semanticLabel: 'cart',
      ),
      onPressed: () => {},
    );
  }
}
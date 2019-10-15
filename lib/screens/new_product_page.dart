import 'package:flutter/material.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/models/product_model.dart';

class NewProductPage extends StatefulWidget {
  NewProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _newProductformKey = GlobalKey<FormState>();
  final _nameEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _captionEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), 
      // Build a form to input new product details
      body: _buildNewProductForm(context),
    );
  }

  Widget _buildNewProductForm(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Form(
        key: _newProductformKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: _buildFormFields(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    return <Widget>[
      _buildNameFormField(),
      SizedBox(height: 16.0),
      _buildPriceFormField(),
      SizedBox(height: 16.0),
      _buildCaptionFormField(),
      SizedBox(height: 16.0),
      _buildDescriptionFormField(),
      SizedBox(height: 16.0),
      _buildSubmitButton(context),
    ];
  }

  Widget _buildDescriptionFormField() {
    return TextFormField(
      controller: _descriptionEditingController,
      keyboardType: TextInputType.multiline,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Product name cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildPriceFormField() {
    return TextFormField(
      controller: _priceEditingController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Price',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
        suffixText: '¥',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Product name cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildNameFormField() {
    return TextFormField(
      controller: _nameEditingController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Product name cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildCaptionFormField() {
    return TextFormField(
      controller: _captionEditingController,
      decoration: InputDecoration(
        labelText: 'Caption',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Product caption cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          child: RaisedButton(
            onPressed: () {
              if (_newProductformKey.currentState.validate()) {
                Scaffold.of(context)
                  .showSnackBar(
                    SnackBar(
                      content: Text('Processing Data'),
                    )
                  );
                
                _addProductToCatalog();
              }
            },
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }

  void _addProductToCatalog() {
    final _product = Product(
      name: _nameEditingController.text,
      caption: _captionEditingController.text,
      description: _descriptionEditingController.text,
      priceInYen: double.parse(
        _priceEditingController.text,
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Add New Product'),
    );
  }
}
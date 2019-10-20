import 'package:badiup/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:badiup/constants.dart' as Constants;
import 'package:badiup/models/product_model.dart';

class NewProductPage extends StatefulWidget {
  NewProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _nameEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _captionEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  bool _formSubmitInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), 
      // Build a form to input new product details
      body: Stack(
        children: _buildNewProductForm(context),
      ),
    );
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _priceEditingController.dispose();
    _captionEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  List<Widget> _buildNewProductForm(BuildContext context) {
    var form = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: _buildFormFields(context),
          ),
        ),
      ),
    );

    var widgetList = List<Widget>();
    if (_formSubmitInProgress) {
      var modal = new Stack(
        children: [
          new Opacity(
            opacity: 0.5,
            child: const ModalBarrier(dismissible: false, color: Colors.black),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );

      widgetList.add(modal);
    }
    widgetList.add(form);
    return widgetList;
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
      _buildSubmitButton(),
    ];
  }

  Widget _buildDescriptionFormField() {
    return TextFormField(
      key: Key(Constants.TestKeys.NEW_PRODUCT_FORM_DESCRIPTION),
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
          return 'Description cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildPriceFormField() {
    return TextFormField(
      key: Key(Constants.TestKeys.NEW_PRODUCT_FORM_PRICE),
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
          return 'Price cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildNameFormField() {
    return TextFormField(
      key: Key(Constants.TestKeys.NEW_PRODUCT_FORM_NAME),
      controller: _nameEditingController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Name cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildCaptionFormField() {
    return TextFormField(
      key: Key(Constants.TestKeys.NEW_PRODUCT_FORM_CAPTION),
      controller: _captionEditingController,
      decoration: InputDecoration(
        labelText: 'Caption',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Caption cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          child: RaisedButton(
            key: Key(
              Constants.TestKeys.NEW_PRODUCT_FORM_SUBMIT_BUTTON),
            onPressed: () async {
              await _submitForm();
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final _product = Product(
      name: _nameEditingController.text,
      caption: _captionEditingController.text,
      description: _descriptionEditingController.text,
      priceInYen: double.parse(
        _priceEditingController.text,
      ),
      created: DateTime.now().toUtc(),
    );

    setState(() {
      _formSubmitInProgress = true;
    });

    await Firestore.instance.collection(
      Constants.DBCollections.PRODUCTS)
      .add(_product.toMap());
    
    setState(() {
      _formSubmitInProgress = false;
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Add New Product'),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/config.dart' as config;
import 'package:badiup/models/product_model.dart';

class NewProductPage extends StatefulWidget {
  NewProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = new GlobalKey<FormState>();

  File _imageFile;

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
        key: _formKey,
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
      widgetList.add(_buildFormSubmitInProgressIndicator());
    }
    widgetList.add(form);
    return widgetList;
  }

  Widget _buildFormSubmitInProgressIndicator() {
    var modal = new Stack(
      children: [
        new Opacity(
          opacity: 0.5,
          child: const ModalBarrier(
            dismissible: false, 
            color: Colors.black
          ),
        ),
        new Center(
          child: new CircularProgressIndicator(),
        ),
      ],
    );
    return modal;
  }

  List<Widget> _buildFormFields(BuildContext context) {
    return <Widget>[
      _buildImageUploadField(),
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

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    File cropped;
    if (selected != null) {
      cropped = await ImageCropper.cropImage(
        sourcePath: selected.path,
        ratioX: 1.0,
        ratioY: 0.7,
        maxWidth: 512,
        maxHeight: 512,
        toolbarColor: kPaletteDeepPurple,
        toolbarWidgetColor: kPaletteWhite,
        toolbarTitle: 'Crop Image'
      );
    }
    
    setState(() {
      _imageFile = cropped ?? selected ?? _imageFile;
    });
  }

  Widget _buildImageUploadField() {
    var widgetList = <Widget> [];

    if (_imageFile != null) {
      widgetList.add(Image.file(_imageFile));
    }

    widgetList.add(_buildImageUploadButtonBar());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }

  ButtonBar _buildImageUploadButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.photo_camera),
          iconSize: 48.0,
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        IconButton(
          key: Key(constants.TestKeys.newProductFormImageGallery),
          icon: Icon(Icons.photo_library),
          iconSize: 48.0,
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildDescriptionFormField() {
    return TextFormField(
      key: Key(constants.TestKeys.newProductFormDescription),
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
      key: Key(constants.TestKeys.newProductFormPrice),
      controller: _priceEditingController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 24.0),
      decoration: InputDecoration(
        labelText: 'Price',
        labelStyle: TextStyle(fontSize: 16.0),
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
      key: Key(constants.TestKeys.newProductFormName),
      controller: _nameEditingController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      maxLength: 10,
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
      key: Key(constants.TestKeys.newProductFormCaption),
      controller: _captionEditingController,
      decoration: InputDecoration(
        labelText: 'Caption',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      maxLength: 15,
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
              constants.TestKeys.newProductFormSubmitButton
            ),
            onPressed: () async {
              if (_formIsValid()) {
                await _submitForm();
                Navigator.pop(context);
              }
            },
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }

  bool _formIsValid() {
    if (_imageFile == null) {
      _buildImageMandatoryDialog();
      return false;
    }

    return _formKey.currentState.validate();
  }

  void _buildImageMandatoryDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Image Required!', 
            style: getAlertStyle(),
          ),
          content: Text('Please upload an image'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _formSubmitInProgress = true;
    });

    String _imageUrl;
    if (_imageFile != null) {
      _imageUrl = await _uploadImageToStorage();
    }
    Product _product = _buildProductModel(_imageUrl);

    await Firestore.instance.collection(
      constants.DBCollections.products)
      .add(_product.toMap());
    
    setState(() {
      _formSubmitInProgress = false;
    });
  }

  Future<String> _uploadImageToStorage() async {
    final FirebaseStorage _storage = 
      FirebaseStorage(storageBucket: config.FIREBASE_STORAGE_URI);

    final String uuid = Uuid().v1();

    final StorageReference ref = _storage
      .ref()
      .child('images')
      .child('products')
      .child('$uuid.png');
    
    final StorageUploadTask uploadTask = ref.putFile(_imageFile);
    final StorageTaskSnapshot snapshot = 
      await uploadTask.onComplete;
    return await snapshot.ref.getDownloadURL() as String;
  }

  Product _buildProductModel(String _imageUrl) {
    final _product = Product(
      name: _nameEditingController.text,
      caption: _captionEditingController.text,
      description: _descriptionEditingController.text,
      priceInYen: double.parse(
        _priceEditingController.text,
      ),
      imageUrl: _imageUrl,
      created: DateTime.now().toUtc(),
    );
    return _product;
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Add New Product'),
    );
  }
}
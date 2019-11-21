import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/config.dart' as config;
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';

class AdminNewProductPage extends StatefulWidget {
  AdminNewProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminNewProductPageState createState() => _AdminNewProductPageState();
}

class _AdminNewProductPageState extends State<AdminNewProductPage> {
  final _formKey = new GlobalKey<FormState>();

  List<File> _imageFiles = [];
  File _imageFileInDisplay;

  final _nameEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
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
            color: Colors.black,
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
      _buildMultipleImageUploadField(),
      _buildNameFormField(),
      _buildDescriptionFormField(),
      SizedBox(height: 16.0),
      _buildPriceFormField(),
      _buildFormButtonBar(),
    ];
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    File cropped;
    if (selected != null) {
      cropped = await ImageCropper.cropImage(
        sourcePath: selected.path,
        ratioX: 1.64,
        ratioY: 1.0,
        toolbarColor: kPaletteDeepPurple,
        toolbarWidgetColor: kPaletteWhite,
        toolbarTitle: 'Crop Image',
      );
    }

    setState(() {
      if (cropped != null) {
        _imageFiles.add(cropped);
      }
      _imageFileInDisplay = cropped;
    });
  }

  Widget _buildMultipleImageUploadField() {
    Widget _imageToDisplay;

    if (_imageFileInDisplay == null) {
      _imageToDisplay = AspectRatio(
        aspectRatio: 1.64,
        child: Image.memory(
          kTransparentImage,
          fit: BoxFit.fill,
        ),
      );
    } else {
      _imageToDisplay = Image.file(_imageFileInDisplay);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _imageToDisplay,
        SizedBox(height: 8.0),
        _buildImageThumbnailBar(),
      ],
    );
  }

  Widget _buildImageThumbnailBar() {
    List<Widget> _barElements = <Widget>[
      _buildUploadImageButton(),
      SizedBox(width: 8.0),
    ];

    _barElements.addAll(_buildImageThumbnails());

    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _barElements,
      ),
    );
  }

  SizedBox _buildUploadImageButton() {
    return SizedBox(
      width: 40,
      child: FittedBox(
        fit: BoxFit.none,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white),
          child: IconButton(
            key: Key(constants.TestKeys.newProductFormImageGallery),
            icon: Icon(Icons.add),
            iconSize: 30.0,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildImageThumbnails() {
    List<Widget> thumbnails = [];

    for (var i = 0; i < _imageFiles.length; i++) {
      thumbnails.add(_buildImageThumbnail(_imageFiles[i]));
      thumbnails.add(SizedBox(width: 8.0));
    }

    return thumbnails;
  }

  Widget _buildImageThumbnail(File imageFile) {
    Border thumbnailBorder;
    if (_imageFileInDisplay == imageFile) {
      thumbnailBorder = Border.all(color: Colors.lightBlue);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _imageFileInDisplay = imageFile;
        });
      },
      child: Container(
        width: 40.0,
        height: 40.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(imageFile),
            fit: BoxFit.cover,
          ),
          border: thumbnailBorder,
        ),
      ),
    );
  }

  Widget _buildDescriptionFormField() {
    return TextFormField(
      key: Key(constants.TestKeys.newProductFormDescription),
      controller: _descriptionEditingController,
      keyboardType: TextInputType.multiline,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: '説明',
        alignLabelWithHint: true,
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
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _buildYenLogo(),
          _buildPriceTextFormField(),
        ],
      ),
    );
  }

  Container _buildPriceTextFormField() {
    return Container(
      width: 120,
      child: TextFormField(
        key: Key(constants.TestKeys.newProductFormPrice),
        controller: _priceEditingController,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 24.0),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(8.0),
          border: InputBorder.none,
          labelStyle: TextStyle(fontSize: 16.0),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Price cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildYenLogo() {
    return SizedBox(
      width: 35,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
        ),
        child: Center(
          child: Text(
            "¥",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameFormField() {
    return TextFormField(
      key: Key(constants.TestKeys.newProductFormName),
      controller: _nameEditingController,
      decoration: InputDecoration(
        labelText: 'タイトル',
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

  Widget _buildFormButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPublishButton(),
        _buildSaveDraftButton(),
      ],
    );
  }

  Padding _buildPublishButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
      ),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        key: Key(constants.TestKeys.newProductFormSubmitButton),
        onPressed: () async {
          if (_formIsValid()) {
            await _submitForm(true);
            Navigator.pop(context);
          }
        },
        child: Text('保存'),
      ),
    );
  }

  Padding _buildSaveDraftButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
      ),
      child: FlatButton(
        color: Colors.white,
        textColor: paletteBlackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        onPressed: () async {
          await _submitForm(false);
          Navigator.pop(context);
        },
        child: Text('下書き'),
      ),
    );
  }

  bool _formIsValid() {
    if (_imageFiles.length == 0) {
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

  Future<void> _submitForm(bool isPublished) async {
    setState(() {
      _formSubmitInProgress = true;
    });

    List<String> _imageUrls;
    if (_imageFiles.length != 0) {
      _imageUrls = await _uploadImagesToStorage();
    }
    Product _product = _buildProductModel(_imageUrls, isPublished);

    await Firestore.instance
        .collection(constants.DBCollections.products)
        .add(_product.toMap());

    setState(() {
      _formSubmitInProgress = false;
    });
  }

  Future<List<String>> _uploadImagesToStorage() async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: config.firebaseStorageUri);

    List<String> imageUrls = [];

    for (var i = 0; i < _imageFiles.length; i++) {
      final String uuid = Uuid().v1();

      final StorageReference ref = _storage
          .ref()
          .child(
            constants.StorageCollections.images,
          )
          .child(
            constants.StorageCollections.products,
          )
          .child('$uuid.png');

      final StorageUploadTask uploadTask = ref.putFile(
        _imageFiles[i],
      );
      final StorageTaskSnapshot snapshot = await uploadTask.onComplete;
      final imageUrl = await snapshot.ref.getDownloadURL() as String;
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Product _buildProductModel(
    List<String> _imageUrls,
    bool isPublished,
  ) {
    final _product = Product(
      name: _nameEditingController.text,
      description: _descriptionEditingController.text,
      priceInYen: double.parse(
        _priceEditingController.text,
      ),
      imageUrls: _imageUrls,
      created: DateTime.now().toUtc(),
      isPublished: isPublished,
    );
    return _product;
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Add New Product'),
    );
  }
}

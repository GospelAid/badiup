import 'dart:io';

import 'package:badiup/screens/multi_select_gallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/config.dart' as config;
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';

class PopupMenuChoice {
  PopupMenuChoice({
    this.title,
    this.action,
  });

  final String title;
  final Function action;
}

class AdminNewProductPage extends StatefulWidget {
  AdminNewProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AdminNewProductPageState createState() => _AdminNewProductPageState();
}

class _AdminNewProductPageState extends State<AdminNewProductPage> {
  final _formKey = GlobalKey<FormState>();

  List<File> _imageFiles = [];
  File _imageFileInDisplay;

  final _nameEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  bool _formSubmitInProgress = false;

  Future<bool> _displayConfirmExitDialog() async {
    if (_isFormEmpty()) {
      return true;
    }

    var result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '変更内容を保存しますか？',
            style: getAlertStyle(),
          ),
          content: Text(
            '変更内容を保存して、後で編集を続けられるようにしますか',
          ),
          actions: _buildConfirmExitDialogActions(
            context,
          ),
        );
      },
    );

    return result ?? false;
  }

  bool _isFormEmpty() {
    return (_imageFiles?.length == 0 ?? true) &&
        (_nameEditingController?.text == "" ?? true) &&
        (_descriptionEditingController?.text == "" ?? true) &&
        (_priceEditingController?.text == "" ?? true);
  }

  List<Widget> _buildConfirmExitDialogActions(
    BuildContext context,
  ) {
    return <Widget>[
      _buildConfirmExitDialogCancelAction(context),
      _buildConfirmExitDialogDiscardAction(context),
      _buildConfirmExitDialogSaveDraftAction(context),
    ];
  }

  FlatButton _buildConfirmExitDialogSaveDraftAction(
    BuildContext context,
  ) {
    return FlatButton(
      child: Text(
        '保存',
        // TODO: Use global variable here
        style: TextStyle(color: const Color(0xFF892C26)),
      ),
      onPressed: () async {
        await _submitForm(false);
        Navigator.pop(context, true);
      },
    );
  }

  FlatButton _buildConfirmExitDialogDiscardAction(BuildContext context) {
    return FlatButton(
      child: Text(
        '削除',
        style: TextStyle(color: paletteBlackColor),
      ),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );
  }

  FlatButton _buildConfirmExitDialogCancelAction(
    BuildContext context,
  ) {
    return FlatButton(
      child: Text(
        'キャンセル',
        style: TextStyle(color: paletteBlackColor),
      ),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _displayConfirmExitDialog,
      child: Scaffold(
        appBar: _buildAppBar(),
        // Build a form to input new product details
        body: _buildNewProductForm(context),
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

  Widget _buildNewProductForm(BuildContext context) {
    var form = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
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

    return Stack(
      children: widgetList,
    );
  }

  Widget _buildFormSubmitInProgressIndicator() {
    var modal = Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: const ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        Center(
          child: CircularProgressIndicator(),
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

  Future<void> _pickImages() async {
    List<Future<File>> selectedImages = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MultiSelectGallery()),
    );

    if (selectedImages != null && selectedImages.length != 0) {
      List<File> images = await Future.wait(selectedImages);

      setState(() {
        _imageFiles.addAll(images);
        _imageFileInDisplay = _imageFiles.last;
      });
    }
  }

  // Not in use right now, but keeping it for reference.
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
      _imageToDisplay = _buildPlaceholderImage();
    } else {
      _imageToDisplay = Image.file(
        _imageFileInDisplay,
        fit: BoxFit.fill,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.64,
          child: _imageToDisplay,
        ),
        SizedBox(height: 8.0),
        _buildImageThumbnailBar(),
      ],
    );
  }

  Stack _buildPlaceholderImage() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          color: const Color(0xFF8D8D8D),
        ),
        Text(
          "写真を選択してください",
          style: TextStyle(
            color: kPaletteWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnailBar() {
    return Container(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildUploadImageButton(),
          SizedBox(width: 4.0),
          _buildDraggableThumbnailListView(),
        ],
      ),
    );
  }

  Widget _buildDraggableThumbnailListView() {
    return Expanded(
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        children: _buildImageThumbnails(),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > _imageFiles.length) {
              newIndex = _imageFiles.length;
            }
            if (oldIndex < newIndex) {
              newIndex--;
            }

            File item = _imageFiles[oldIndex];
            _imageFiles.remove(item);
            _imageFiles.insert(newIndex, item);
          });
        },
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
            onPressed: () => _pickImages(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildImageThumbnails() {
    List<Widget> thumbnails = [];

    for (var i = 0; i < _imageFiles.length; i++) {
      thumbnails.add(_buildImageThumbnail(_imageFiles[i]));
    }

    return thumbnails;
  }

  Widget _buildImageThumbnail(File imageFile) {
    return GestureDetector(
      key: Key(imageFile.path),
      onTap: () {
        setState(() {
          _imageFileInDisplay = imageFile;
        });
      },
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Container(
          width: 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
            border: _buildThumbnailBorder(imageFile),
          ),
        ),
      ),
    );
  }

  Border _buildThumbnailBorder(File imageFile) {
    Border thumbnailBorder;
    if (_imageFileInDisplay == imageFile) {
      thumbnailBorder = Border.all(
        color: paletteBlackColor,
        width: 2.0,
      );
    }
    return thumbnailBorder;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPublishButton(),
        _buildSaveDraftButton(),
      ],
    );
  }

  Widget _buildPublishButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
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
          child: Text('公開'),
        ),
      ),
    );
  }

  Widget _buildSaveDraftButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
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
      priceInYen: double.tryParse(_priceEditingController.text) ?? 0,
      imageUrls: _imageUrls,
      created: DateTime.now().toUtc(),
      isPublished: isPublished,
    );
    return _product;
  }

  void _performPopupMenuAction(PopupMenuChoice choice) {
    choice.action();
  }

  Widget _buildAppBar() {
    List<PopupMenuChoice> popupMenuChoices = _buildPopupMenuChoices();

    return AppBar(
      title: Text('編集'),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) {
            return popupMenuChoices.map((PopupMenuChoice choice) {
              return PopupMenuItem<PopupMenuChoice>(
                value: choice,
                child: Text(choice.title),
              );
            }).toList();
          },
          onSelected: _performPopupMenuAction,
        ),
      ],
    );
  }

  List<PopupMenuChoice> _buildPopupMenuChoices() {
    List<PopupMenuChoice> popupMenuChoices = <PopupMenuChoice>[
      PopupMenuChoice(
        title: '変更を破棄',
        action: () => _displayConfirmDiscardDialog(),
      ),
    ];
    return popupMenuChoices;
  }

  Future<void> _displayConfirmDiscardDialog() {
    if (_isFormEmpty()) {
      Navigator.pop(context);
      return null;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '画像を削除',
            style: getAlertStyle(),
          ),
          content: Text('本当に削除しますか？この操作は取り消しできません。'),
          actions: _buildConfirmDiscardDialogActions(
            context,
          ),
        );
      },
    );
  }

  List<Widget> _buildConfirmDiscardDialogActions(
    BuildContext context,
  ) {
    return <Widget>[
      FlatButton(
        child: Text(
          'キャンセル',
          style: TextStyle(color: paletteBlackColor),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      FlatButton(
        child: Text(
          '削除',
          // TODO: Use global variable here
          style: TextStyle(color: const Color(0xFF892C26)),
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    ];
  }
}

import 'dart:collection';
import 'dart:io';

import 'package:badiup/colors.dart';
import 'package:badiup/config.dart' as config;
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/product_model.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:badiup/screens/multi_select_gallery.dart';
import 'package:badiup/test_keys.dart';
import 'package:badiup/utilities.dart';
import 'package:badiup/widgets/stock_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

enum PublishStatus {
  Published,
  Draft,
}

class PopupMenuChoice {
  PopupMenuChoice({
    this.title,
    this.action,
  });

  final String title;
  final Function action;
}

class AdminNewProductPage extends StatefulWidget {
  AdminNewProductPage({
    Key key,
    this.title,
    this.productDocumentId,
  }) : super(key: key);

  final String title;
  final String productDocumentId;

  @override
  _AdminNewProductPageState createState() => _AdminNewProductPageState();
}

class _AdminNewProductPageState extends State<AdminNewProductPage> {
  bool _updatingExistingProduct = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  Product _product;

  List<Object> _productImages = [];
  int _indexOfImageInDisplay = 0;

  final _nameEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _quantityEditingController = TextEditingController();
  Category _productCategory;
  StockType _productStockType;

  bool _shouldDisplayStock = false;
  LinkedHashMap<StockIdentifier, int> _productStockMap =
      LinkedHashMap<StockIdentifier, int>(equals: (
    StockIdentifier id1,
    StockIdentifier id2,
  ) {
    return id1.color == id2.color && id1.size == id2.size;
  });

  PublishStatus _productPublishStatus = PublishStatus.Draft;

  bool _formSubmitInProgress = false;

  @override
  initState() {
    super.initState();
    if (widget.productDocumentId != null) {
      _updatingExistingProduct = true;

      _loadProductInfoFromDb();
    } else {
      _productCategory = Category.misc;
      _productStockType = StockType.quantityOnly;
    }
  }

  Future<void> _loadProductInfoFromDb() async {
    _product = Product.fromSnapshot(await Firestore.instance
        .collection(constants.DBCollections.products)
        .document(widget.productDocumentId)
        .get());

    _nameEditingController.text = _product.name;
    _descriptionEditingController.text = _product.description;
    _priceEditingController.text = _product.priceInYen?.toString();

    setState(() {
      _productImages.addAll(_product.imageUrls);

      if (_productImages.length > 0) {
        _indexOfImageInDisplay = _productImages.length - 1;
      }

      _productCategory = _product.category;

      if (_product.stock != null) {
        _productStockType = _product.stock.stockType;

        _product.stock.items.forEach((stock) {
          _productStockMap.putIfAbsent(
              StockIdentifier(color: stock.color, size: stock.size),
              () => stock.quantity);

          if (_productStockType == StockType.quantityOnly) {
            _quantityEditingController.text =
                _product.stock.items.first.quantity.toString();
          } else {
            _shouldDisplayStock = true;
          }
        });
      } else {
        _productStockType = StockType.quantityOnly;
      }

      _productPublishStatus =
          _product.isPublished ? PublishStatus.Published : PublishStatus.Draft;
    });
  }

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
    return (_productImages?.length == 0 ?? true) &&
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
        style: TextStyle(color: paletteForegroundColor),
      ),
      onPressed: () async {
        await _submitForm(PublishStatus.Draft);
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
        key: _scaffoldKey,
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
      child: _buildNewProductFormInternal(context),
    );

    var widgetList = List<Widget>();
    widgetList.add(form);

    if (_formSubmitInProgress) {
      widgetList.add(buildFormSubmitInProgressIndicator());
    }

    return Stack(
      children: widgetList,
    );
  }

  Widget _buildNewProductFormInternal(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          key: Key(
            makeTestKeyString(
              TKUsers.admin,
              TKScreens.addProduct,
              "form",
            ),
          ),
          slivers: _buildFormFields(context),
        ),
      ),
    );
  }

  Widget _buildQuantityFormField() {
    return TextFormField(
      controller: _quantityEditingController,
      decoration: InputDecoration(
        labelText: '在庫量',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.isEmpty) {
          return '在庫量が入力されていません';
        }
        return null;
      },
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    var widgetList1 = <Widget>[
      _buildMultipleImageUploadField(),
      _buildNameFormField(),
      _buildDescriptionFormField(),
      SizedBox(height: 16.0),
      _buildPriceFormField(),
      SizedBox(height: 32.0),
      _buildCategoryFormField(),
      _buildStockTypeFormField(),
      SizedBox(height: 4.0),
    ];

    if (_productStockType == StockType.quantityOnly) {
      widgetList1.add(_buildQuantityFormField());
      widgetList1.add(SizedBox(height: 16.0));
    }

    List<Widget> widgetList2 = [];
    if (_updatingExistingProduct) {
      widgetList2.add(_buildPublishSwitchBar());
      widgetList2.add(_buildSaveChangesButtonBar());
    } else {
      widgetList2.add(_buildPublishDraftButtonBar());
    }

    return _getSliverList(widgetList1, widgetList2);
  }

  List<Widget> _getSliverList(
    List<Widget> widgetList1,
    List<Widget> widgetList2,
  ) {
    List<Widget> sliverList = <Widget>[
      SliverList(delegate: SliverChildListDelegate(widgetList1)),
    ];

    if (_shouldDisplayStock) {
      sliverList.add(SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildListDelegate(_buildStockList()),
      ));
    }

    sliverList.add(SliverList(delegate: SliverChildListDelegate(widgetList2)));

    return sliverList;
  }

  List<Widget> _buildStockList() {
    List<Widget> _widgetList = [];

    _productStockMap.forEach((stockIdentifier, quantity) {
      _widgetList.add(_buildStockItem(StockItem(
        color: stockIdentifier.color,
        size: stockIdentifier.size,
        quantity: quantity,
      )));
    });

    _widgetList.add(_buildAddStockButton());

    return _widgetList;
  }

  Widget _buildAddStockButton() {
    return GestureDetector(
      onTap: _addStockToMap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: paletteGreyColor),
        ),
        child: Icon(Icons.add, size: 60, color: paletteGreyColor),
      ),
    );
  }

  void _addStockToMap() async {
    StockItem newStockItem = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StockSelector(
                productStockType: _productStockType,
              )),
    );

    if (newStockItem != null) {
      var id = _productStockMap.keys.firstWhere(
        (key) =>
            key.color == newStockItem.color && key.size == newStockItem.size,
        orElse: () => null,
      );

      if (id != null) {
        _productStockMap[id] += newStockItem.quantity;
      } else {
        _productStockMap.putIfAbsent(
          StockIdentifier(color: newStockItem.color, size: newStockItem.size),
          () => newStockItem.quantity,
        );
      }
    }
  }

  Future<void> _updateStockInMap(StockItem stockItem) async {
    StockItem updatedStockItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockSelector(productStockItem: stockItem),
      ),
    );

    if (updatedStockItem != null) {
      var id = _productStockMap.keys.firstWhere(
        (key) =>
            key.color == updatedStockItem.color &&
            key.size == updatedStockItem.size,
        orElse: () => null,
      );

      if (id != null) {
        _productStockMap[id] = updatedStockItem.quantity;
      }
    }
  }

  Widget _buildStockItem(StockItem stockItem) {
    return GestureDetector(
      onTap: () async {
        await _updateStockInMap(stockItem);
      },
      child: Container(
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          color: _productStockType == StockType.sizeOnly
              ? Colors.transparent
              : getDisplayColorForItemColor(stockItem.color),
          border: _productStockType == StockType.sizeOnly
              ? Border.all(color: paletteGreyColor)
              : null,
        ),
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            _buildStockItemQuantity(stockItem),
            _buildDeleteStockItemButton(stockItem),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_buildStockItemText(stockItem)],
            ),
          ],
        ),
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

  Widget _buildDeleteStockItemButton(StockItem stockItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          alignment: AlignmentDirectional.center,
          height: 35,
          width: 32,
          child: IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(Icons.delete,
                color: _productStockType != StockType.sizeOnly &&
                        stockItem.color == ItemColor.black
                    ? paletteGreyColor
                    : paletteBlackColor,
                size: 22),
            onPressed: () {
              _displayDeleteStockItemDialog(stockItem);
            },
          ),
        ),
      ],
    );
  }

  void _displayDeleteStockItemDialog(StockItem stockItem) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '削除してよろしいですか？',
            style: getAlertStyle(),
          ),
          content: Text('この操作は取り消しできません。'),
          actions: _buildDeleteStockItemDialogActions(context, stockItem),
        );
      },
    );
  }

  List<Widget> _buildDeleteStockItemDialogActions(
      BuildContext context, StockItem stockItem) {
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
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () async {
          setState(() {
            _productStockMap.removeWhere((key, q) =>
                key.color == stockItem.color && key.size == stockItem.size);
          });
          Navigator.pop(context);
        },
      ),
    ];
  }

  Widget _buildStockItemText(StockItem stockItem) {
    Color _color = _productStockType == StockType.sizeOnly
        ? paletteGreyColor2
        : getDisplayTextColorForItemColor(stockItem.color);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _productStockType == StockType.colorOnly
              ? Container()
              : Text(
                  getDisplayTextForItemSize(stockItem.size),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
          _productStockType == StockType.sizeOnly
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

  Widget _buildStockTypeFormField() {
    var _textStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      alignment: AlignmentDirectional.centerStart,
      child: _productStockMap.isEmpty
          ? _buildStockTypePicker(_textStyle)
          : _buildStockTypeDisplay(_textStyle),
    );
  }

  Widget _buildCategoryFormField() {
    var _borderSide = BorderSide(width: 0.3, color: paletteBlackColor);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        border: Border(top: _borderSide, bottom: _borderSide),
      ),
      child: _buildCategoryButton(),
    );
  }

  Widget _buildStockTypeDisplay(TextStyle textStyle) {
    var controller = TextEditingController(
      text: "カテゴリタイプ：" + getDisplayTextForStockType(_productStockType),
    );

    return TextField(
      readOnly: true,
      controller: controller,
      style: textStyle,
    );
  }

  Widget _buildStockTypePicker(TextStyle textStyle) {
    return ButtonTheme(
      child: DropdownButton<StockType>(
        isExpanded: true,
        value: _productStockType ?? StockType.sizeAndColor,
        icon: Icon(Icons.keyboard_arrow_down, color: paletteBlackColor),
        iconSize: 32,
        elevation: 2,
        style: textStyle,
        underline: Container(height: 0, color: paletteBlackColor),
        onChanged: (StockType newValue) {
          setState(() {
            if (newValue == StockType.quantityOnly) {
              _shouldDisplayStock = false;
            } else {
              _shouldDisplayStock = true;
            }
            _productStockType = newValue;
          });
        },
        items: StockType.values
            .map<DropdownMenuItem<StockType>>((StockType value) {
          return DropdownMenuItem<StockType>(
            value: value,
            child: Text("カテゴリタイプ：" + getDisplayTextForStockType(value),
                style: textStyle),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryButton() {
    var _textStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return ButtonTheme(
      child: DropdownButton<Category>(
        isExpanded: true,
        value: _productCategory ?? Category.misc,
        icon: Icon(Icons.keyboard_arrow_down, color: paletteBlackColor),
        iconSize: 32,
        elevation: 2,
        style: _textStyle,
        underline: Container(height: 0, color: paletteBlackColor),
        onChanged: (Category newValue) {
          setState(() {
            _productCategory = newValue;
          });
        },
        items:
            Category.values.map<DropdownMenuItem<Category>>((Category value) {
          return DropdownMenuItem<Category>(
            value: value,
            child: Text("カテゴリ：" + getDisplayText(value), style: _textStyle),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPublishSwitchBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.3,
            color: paletteBlackColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "公開する",
            style: TextStyle(
              color: paletteBlackColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildPublishSwitch(),
        ],
      ),
    );
  }

  Widget _buildPublishSwitch() {
    return Switch(
      value: _productPublishStatus == PublishStatus.Published,
      onChanged: (value) {
        if (value == false || _formIsValid()) {
          setState(() {
            _productPublishStatus =
                value ? PublishStatus.Published : PublishStatus.Draft;
          });
        }
      },
      activeTrackColor: paletteForegroundColor,
      activeColor: kPaletteWhite,
    );
  }

  Future<void> _pickImages() async {
    List<Future<File>> selectedImages = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MultiSelectGallery()),
    );

    if (selectedImages != null && selectedImages.length != 0) {
      List<File> images = await Future.wait(selectedImages);
      List<File> croppedImages = await _cropImages(images);

      if (croppedImages != null && croppedImages.length != 0) {
        setState(() {
          _productImages.addAll(croppedImages);
          _indexOfImageInDisplay = _productImages.length - 1;
        });
      }
    }
  }

  Future<List<File>> _cropImages(List<File> images) async {
    List<File> croppedImages = List<File>();

    for (var i = 0; i < images.length; i++) {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: images[i].path,
        aspectRatio: CropAspectRatio(
          ratioX: 1.64,
          ratioY: 1.0,
        ),
        iosUiSettings: IOSUiSettings(rotateButtonsHidden: true),
        androidUiSettings: AndroidUiSettings(
          toolbarColor: paletteForegroundColor,
          toolbarWidgetColor: kPaletteWhite,
          toolbarTitle: 'Crop Image',
        ),
      );

      if (croppedImage != null) {
        croppedImages.add(croppedImage);
      }
    }
    return croppedImages;
  }

  Widget _buildMultipleImageUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.64,
          child: _buildImageToDisplay(),
        ),
        SizedBox(height: 8.0),
        _buildImageThumbnailBar(),
      ],
    );
  }

  Widget _buildImageToDisplay() {
    var stackWidgetList = <Widget>[
      _buildInnerStackForImageDisplay(),
    ];

    if (_productImages != null && _productImages.length > 1) {
      stackWidgetList.add(_buildImageSliderButtons());
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: stackWidgetList,
    );
  }

  Widget _buildOpacityLayerForDeleteButton() {
    return Opacity(
      opacity: 0.61,
      child: Container(
        height: constants.imageHeight / 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.transparent,
              paletteBlackColor,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInnerStackForImageDisplay() {
    var stackWidgetList = <Widget>[
      _buildImageForDisplay(),
    ];

    if (_productImages != null && _productImages.length != 0) {
      stackWidgetList.add(_buildOpacityLayerForDeleteButton());
      stackWidgetList.add(_buildImageDeleteButton());
    }

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: stackWidgetList,
    );
  }

  Widget _buildImageForDisplay() {
    Widget _imageToDisplay;

    if (_productImages?.length == 0 ?? true) {
      _imageToDisplay = _buildPlaceholderImage();
    } else {
      _imageToDisplay = _productImages[_indexOfImageInDisplay] is File
          ? Image.file(
              _productImages[_indexOfImageInDisplay] as File,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            )
          : FadeInImage.memoryNetwork(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
              placeholder: kTransparentImage,
              image: _productImages[_indexOfImageInDisplay] as String,
            );
    }

    return _imageToDisplay;
  }

  Widget _buildImageDeleteButton() {
    return IconButton(
      color: kPaletteWhite,
      icon: buildIconWithShadow(Icons.delete),
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                '画像を削除',
                style: getAlertStyle(),
              ),
              content: Text('本当に削除しますか？この操作は取り消しできません。'),
              actions: _buildImageDeleteDialogActions(
                context,
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildImageDeleteDialogActions(
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
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () {
          Navigator.pop(context);
          _deleteImage();
        },
      ),
    ];
  }

  void _deleteImage() {
    setState(() {
      _productImages.removeAt(_indexOfImageInDisplay);
      if (_productImages.length != 0) {
        if (_indexOfImageInDisplay == _productImages.length) {
          _indexOfImageInDisplay--;
        }
        _indexOfImageInDisplay = _indexOfImageInDisplay % _productImages.length;
      } else {
        _indexOfImageInDisplay = 0;
      }
    });
  }

  Widget _buildImageSliderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: buildIconWithShadow(Icons.chevron_left, iconSize: 32),
          onPressed: () {
            setState(() {
              _indexOfImageInDisplay =
                  (_indexOfImageInDisplay - 1) % _productImages.length;
            });
          },
        ),
        IconButton(
          icon: buildIconWithShadow(Icons.chevron_right, iconSize: 32),
          onPressed: () {
            setState(() {
              _indexOfImageInDisplay =
                  (_indexOfImageInDisplay + 1) % _productImages.length;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return GestureDetector(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "placeholderImage",
      )),
      onTap: _pickImages,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(color: paletteDarkGreyColor),
          Text(
            "写真を選択してください",
            style: TextStyle(
              color: kPaletteWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
            if (newIndex > _productImages.length) {
              newIndex = _productImages.length;
            }
            if (oldIndex < newIndex) {
              newIndex--;
            }

            Object item = _productImages[oldIndex];
            _productImages.remove(item);
            _productImages.insert(newIndex, item);
            _indexOfImageInDisplay = newIndex;
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

    for (var i = 0; i < _productImages.length; i++) {
      thumbnails.add(_buildImageThumbnail(i));
    }

    return thumbnails;
  }

  Widget _buildImageThumbnail(int thumbnailIndex) {
    var imageObject = _productImages[thumbnailIndex];

    return GestureDetector(
      key:
          Key(imageObject is File ? imageObject.path : (imageObject as String)),
      onTap: () {
        setState(() {
          _indexOfImageInDisplay = thumbnailIndex;
        });
      },
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Container(
          width: 40.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageObject is File
                  ? FileImage(imageObject)
                  : NetworkImage(imageObject as String),
              fit: BoxFit.cover,
            ),
            border: _buildThumbnailBorder(thumbnailIndex),
          ),
        ),
      ),
    );
  }

  Border _buildThumbnailBorder(int thumbnailIndex) {
    Border thumbnailBorder;
    if (_indexOfImageInDisplay == thumbnailIndex) {
      thumbnailBorder = Border.all(
        color: paletteBlackColor,
        width: 2.0,
      );
    }
    return thumbnailBorder;
  }

  Widget _buildDescriptionFormField() {
    return TextFormField(
      key: Key(makeTestKeyString(
        TKUsers.admin,
        TKScreens.addProduct,
        "description",
      )),
      controller: _descriptionEditingController,
      keyboardType: TextInputType.multiline,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: '説明',
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return '説明が入力されていません';
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
        key: Key(makeTestKeyString(
          TKUsers.admin,
          TKScreens.addProduct,
          "price",
        )),
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
      key: Key(makeTestKeyString(TKUsers.admin, TKScreens.addProduct, "title")),
      controller: _nameEditingController,
      decoration: InputDecoration(
        labelText: 'タイトル',
      ),
      maxLength: 20,
      validator: (value) {
        if (value.isEmpty) {
          return 'タイトルが入力されていません';
        }
        return null;
      },
    );
  }

  Widget _buildPublishDraftButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPublishButton(),
        _buildSaveDraftButton(),
      ],
    );
  }

  Widget _buildSaveChangesButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildSaveChangesButton(),
        _buildDiscardChangesButton(),
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
          onPressed: () async {
            if (_formIsValid()) {
              await _submitForm(PublishStatus.Published);
              Navigator.pop(context);
            }
          },
          child: Text('公開'),
        ),
      ),
    );
  }

  Widget _buildSaveChangesButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: RaisedButton(
          key: Key(makeTestKeyString(
            TKUsers.admin,
            TKScreens.editProduct,
            "saveChanges",
          )),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: () async {
            if (_productPublishStatus == PublishStatus.Published) {
              if (_formIsValid()) {
                _displayConfirmSaveChangesDialog(context);
              }
            } else {
              await _submitForm(_productPublishStatus);
              Navigator.pop(context);
            }
          },
          child: Text('変更を保存'),
        ),
      ),
    );
  }

  void _displayConfirmSaveChangesDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'この商品は既に公開されています',
            style: getAlertStyle(),
          ),
          content: Text('変更内容を保存して、上書き公開してもよろしいですか？'),
          actions: _buildSaveChangesDialogActions(context),
        );
      },
    );
  }

  List<Widget> _buildSaveChangesDialogActions(BuildContext context) {
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
          '上書き公開',
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () async {
          if (_formIsValid()) {
            Navigator.pop(context);
            await _submitForm(_productPublishStatus);
            Navigator.pop(_scaffoldKey.currentContext);
          }
        },
      ),
    ];
  }

  Widget _buildSaveDraftButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: FlatButton(
          key: Key(makeTestKeyString(
            TKUsers.admin,
            TKScreens.addProduct,
            "saveDraft",
          )),
          color: Colors.white,
          textColor: paletteBlackColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: () async {
            await _submitForm(PublishStatus.Draft);
            Navigator.pop(context);
          },
          child: Text('下書き'),
        ),
      ),
    );
  }

  Widget _buildDiscardChangesButton() {
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
          onPressed: () {
            _displayDiscardChangesDialog();
          },
          child: Text('変更を破棄'),
        ),
      ),
    );
  }

  void _displayDiscardChangesDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '変更を破棄してよろしいですか？',
            style: getAlertStyle(),
          ),
          content: Text('この操作は取り消しできません。'),
          actions: _buildDiscardChangesDialogActions(context),
        );
      },
    );
  }

  List<Widget> _buildDiscardChangesDialogActions(BuildContext context) {
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
          '変更を破棄',
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () async {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    ];
  }

  bool _formIsValid() {
    bool _result = _formKey.currentState.validate();

    String _message = "";

    if (_productImages.length == 0) {
      _message += '写真　';
    }

    if (_priceEditingController.text.isEmpty) {
      _message += '値段　';
    }

    if (_message != "") {
      _message += "が入力されていません。編集画面に戻って入力してください。";
      _buildRequiredItemsMissingDialog(_message);
      _result = false;
    }

    return _result;
  }

  void _buildRequiredItemsMissingDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '入力されていない項目があります',
            style: getAlertStyle(),
          ),
          content: Text(message),
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

  Future<void> _submitForm(PublishStatus publishStatus) async {
    setState(() {
      _formSubmitInProgress = true;
    });

    List<String> _imageUrls = await _uploadImagesToStorage();
    Product _productModel = _buildProductModel(_imageUrls, publishStatus);

    if (_updatingExistingProduct) {
      await Firestore.instance
          .collection(constants.DBCollections.products)
          .document(_product.documentId)
          .updateData(_productModel.toMap());
    } else {
      await Firestore.instance
          .collection(constants.DBCollections.products)
          .add(_productModel.toMap());
    }

    setState(() {
      _formSubmitInProgress = false;
    });
  }

  Future<List<String>> _uploadImagesToStorage() async {
    List<Future<String>> imageUrls = [];

    for (var i = 0; i < _productImages.length; i++) {
      if (_productImages[i] is File) {
        imageUrls.add(_uploadImageAndGetUrl(_productImages[i] as File));
      } else {
        imageUrls.add(Future(() => _productImages[i] as String));
      }
    }

    return Future.wait(imageUrls);
  }

  Future<String> _uploadImageAndGetUrl(File imageFile) async {
    FirebaseStorage _storage =
        FirebaseStorage(storageBucket: config.firebaseStorageUri);

    StorageReference ref = _storage
        .ref()
        .child(constants.StorageCollections.images)
        .child(constants.StorageCollections.products)
        .child('${Uuid().v1()}.png');

    StorageUploadTask uploadTask = ref.putFile(imageFile);
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;

    String url = await snapshot.ref.getDownloadURL() as String;

    return url;
  }

  Product _buildProductModel(
    List<String> _imageUrls,
    PublishStatus publishStatus,
  ) {
    List<StockItem> stockItemList = List<StockItem>();
    if (_productStockType == StockType.quantityOnly) {
      var quantity = int.tryParse(_quantityEditingController.text) ?? 0;
      if (quantity != 0) {
        stockItemList.add(StockItem(quantity: quantity));
      }
    } else {
      stockItemList = _productStockMap.entries
          .map((e) => StockItem(
                color: e.key.color,
                size: e.key.size,
                quantity: e.value,
              ))
          .toList();
    }

    final _product = Product(
      name: _nameEditingController.text,
      description: _descriptionEditingController.text,
      priceInYen: double.tryParse(_priceEditingController.text) ?? 0,
      imageUrls: _imageUrls,
      created: DateTime.now().toUtc(),
      isPublished: publishStatus == PublishStatus.Published,
      category: _productCategory,
      stock: Stock(items: stockItemList, stockType: _productStockType),
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
            '変更を破棄',
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
          style: TextStyle(color: paletteForegroundColor),
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    ];
  }
}

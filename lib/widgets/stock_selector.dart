import 'package:badiup/colors.dart';
import 'package:badiup/models/stock_model.dart';
import 'package:flutter/material.dart';

class StockSelector extends StatefulWidget {
  StockSelector({Key key, this.productStock}) : super(key: key);

  final Stock productStock;

  @override
  _StockSelectorState createState() => _StockSelectorState();
}

class _StockSelectorState extends State<StockSelector> {
  ItemSize _stockSize = ItemSize.na;
  ItemColor _stockColor = ItemColor.na;
  var _stockQuantityEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    if (widget.productStock != null) {
      _stockSize = widget.productStock.identifier.size;
      _stockColor = widget.productStock.identifier.color;
      _stockQuantityEditingController.text =
          widget.productStock.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: _buildAddStockScreen());
  }

  Widget _buildAddStockScreen() {
    var _textStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.productStock == null
              ? _buildStockSizePicker(_textStyle)
              : _buildStockSizeDisplay(_textStyle),
          widget.productStock == null
              ? _buildStockColorPicker(_textStyle)
              : _buildStockColorDisplay(_textStyle),
          _buildStockQuantityPicker(),
          _buildStockFormActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStockColorDisplay(TextStyle textStyle) {
    var controller = TextEditingController(
      text: _getStockColorDisplayText(_stockColor),
    );

    return TextField(
      readOnly: true,
      controller: controller,
      style: textStyle,
    );
  }

  Widget _buildStockSizeDisplay(TextStyle textStyle) {
    var controller = TextEditingController(
      text: _getStockSizeDisplayText(_stockSize),
    );

    return TextField(
      readOnly: true,
      controller: controller,
      style: textStyle,
    );
  }

  String _getStockSizeDisplayText(ItemSize size) =>
      "サイズ：" + getDisplayTextForItemSize(size);

  String _getStockColorDisplayText(ItemColor color) =>
      "色：" + getDisplayTextForItemColor(color);

  Widget _buildStockFormActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _buildStockFormCancelButton(),
          SizedBox(width: 12),
          _buildStockFormSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildStockFormSubmitButton() {
    return GestureDetector(
      child: Text(
        '完了',
        style: TextStyle(
          color: paletteForegroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(
          context,
          Stock(
            identifier: StockIdentifier(color: _stockColor, size: _stockSize),
            quantity: int.tryParse(_stockQuantityEditingController.text) ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildStockFormCancelButton() {
    return GestureDetector(
      child: Text(
        'キャンセル',
        style: TextStyle(color: paletteBlackColor),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildStockQuantityPicker() {
    return TextFormField(
      controller: _stockQuantityEditingController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '在庫',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildStockColorPicker(TextStyle _textStyle) {
    return _buildPicker<ItemColor>(
      pickerValue: _stockColor,
      textStyle: _textStyle,
      valueOnChanged: widget.productStock == null
          ? (ItemColor newValue) {
              setState(() {
                _stockColor = newValue;
              });
            }
          : null,
      items: ItemColor.values.map<DropdownMenuItem<ItemColor>>(
        (ItemColor value) {
          return DropdownMenuItem<ItemColor>(
            value: value,
            child: Text(
              _getStockColorDisplayText(value),
              style: _textStyle,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildPicker<T>({
    T pickerValue,
    TextStyle textStyle,
    Function valueOnChanged,
    List<DropdownMenuItem<T>> items,
  }) {
    return DropdownButton<T>(
      isExpanded: true,
      value: pickerValue,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 32,
      elevation: 2,
      style: textStyle,
      underline: Container(height: 1, color: paletteDarkGreyColor),
      onChanged: valueOnChanged,
      items: items,
    );
  }

  Widget _buildStockSizePicker(TextStyle _textStyle) {
    return _buildPicker<ItemSize>(
      pickerValue: _stockSize,
      textStyle: _textStyle,
      valueOnChanged: widget.productStock == null
          ? (ItemSize newValue) {
              setState(() {
                _stockSize = newValue;
              });
            }
          : null,
      items: ItemSize.values.map<DropdownMenuItem<ItemSize>>(
        (ItemSize value) {
          return DropdownMenuItem<ItemSize>(
            value: value,
            child: Text(
              _getStockSizeDisplayText(value),
              style: _textStyle,
            ),
          );
        },
      ).toList(),
    );
  }
}

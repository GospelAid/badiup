import 'package:badiup/colors.dart';
import 'package:badiup/models/tracking_details.dart';
import 'package:flutter/material.dart';

class OrderTrackingDetailsPage extends StatefulWidget {
  OrderTrackingDetailsPage({Key key}) : super(key: key);

  @override
  _StockOrderTrackingDetailsPageState createState() =>
      _StockOrderTrackingDetailsPageState();
}

class _StockOrderTrackingDetailsPageState
    extends State<OrderTrackingDetailsPage> {
  DeliveryMethod _selectedDeliveryMethod;
  TextEditingController _trackingCodeController = TextEditingController();
  TextEditingController _trackingCodeConfirmationController =
      TextEditingController();
  bool _formIsValid = false;
  bool _trackingCodeMatches = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("追跡番号の入力"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildDeliveryMethodSelector(),
            _buildTrackingCodeFormField(),
            _buildTrackingCodeConfirmationFormField(),
            _trackingCodeMatches
                ? Container()
                : _buildTrackingCodeMismatchError(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildCancelButton(),
                _buildSubmitButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCodeMismatchError() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(
            "一致しません",
            style: TextStyle(color: paletteForegroundColor),
          ),
        ],
      ),
    );
  }

  void _checkFormValidity() {
    setState(() {
      _trackingCodeMatches = _trackingCodeController != null &&
          _trackingCodeController.text.isNotEmpty &&
          _trackingCodeConfirmationController != null &&
          _trackingCodeConfirmationController.text.isNotEmpty &&
          _trackingCodeController.text ==
              _trackingCodeConfirmationController.text;
      _formIsValid = _selectedDeliveryMethod != null && _trackingCodeMatches;
    });
  }

  Widget _buildSubmitButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: RaisedButton(
          color: _formIsValid ? paletteForegroundColor : paletteGreyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: () async {
            Navigator.pop(
              context,
              TrackingDetails(
                deliveryMethod: _selectedDeliveryMethod,
                code: _trackingCodeController.text,
              ),
            );
          },
          child: Text('発送する'),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: RaisedButton(
          color: kPaletteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          child: Text('キャンセル'),
        ),
      ),
    );
  }

  Widget _buildTrackingCodeConfirmationFormField() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: AlignmentDirectional.centerStart,
      height: 67,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        textCapitalization: TextCapitalization.characters,
        controller: _trackingCodeConfirmationController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: "確認用",
        ),
        onChanged: (value) {
          _checkFormValidity();
        },
      ),
    );
  }

  Widget _buildTrackingCodeFormField() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: AlignmentDirectional.centerStart,
      height: 67,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        textCapitalization: TextCapitalization.characters,
        controller: _trackingCodeController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: "追跡番号",
        ),
        onChanged: (value) {
          _checkFormValidity();
        },
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    var optionTextStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    var hintTextStyle = TextStyle(
      color: paletteDarkGreyColor,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );

    return Container(
      padding: EdgeInsets.all(16),
      alignment: AlignmentDirectional.centerStart,
      height: 67,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: kPaletteWhite,
      ),
      child: _buildDeliveryMethodSelectorInternal(
        hintTextStyle,
        optionTextStyle,
      ),
    );
  }

  DropdownButton<DeliveryMethod> _buildDeliveryMethodSelectorInternal(
    TextStyle hintTextStyle,
    TextStyle optionTextStyle,
  ) {
    return DropdownButton<DeliveryMethod>(
      isExpanded: true,
      value: _selectedDeliveryMethod,
      hint: Text("配送方法を選択する", style: hintTextStyle),
      icon: Icon(Icons.keyboard_arrow_down, color: paletteBlackColor),
      iconSize: 32,
      elevation: 2,
      style: optionTextStyle,
      underline: Container(height: 0),
      onChanged: (DeliveryMethod newValue) {
        setState(() {
          _selectedDeliveryMethod = newValue;
        });
        _checkFormValidity();
      },
      items: DeliveryMethod.values
          .map<DropdownMenuItem<DeliveryMethod>>((DeliveryMethod value) {
        return DropdownMenuItem<DeliveryMethod>(
          value: value,
          child: Text(
            getAdminDisplayTextForDeliveryMethod(value),
            style: optionTextStyle,
          ),
        );
      }).toList(),
    );
  }
}

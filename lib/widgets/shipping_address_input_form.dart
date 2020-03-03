import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

TextEditingController postcodeTextController;
TextEditingController prefectureTextController;
TextEditingController municipalityTextController;
TextEditingController buildingNameTextController;
TextEditingController phoneNumberTextController;

class ShippingAddressInputForm extends StatefulWidget {
  @override
  _ShippingAddressInputFormState createState() =>
      _ShippingAddressInputFormState();
}

class _ShippingAddressInputFormState extends State<ShippingAddressInputForm> {
  void initState() {
    super.initState();
    postcodeTextController = TextEditingController();
    prefectureTextController = TextEditingController();
    municipalityTextController = TextEditingController();
    buildingNameTextController = TextEditingController();
    phoneNumberTextController = TextEditingController();
  }

  void dispose() {
    postcodeTextController.dispose();
    prefectureTextController.dispose();
    municipalityTextController.dispose();
    buildingNameTextController.dispose();
    phoneNumberTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.0, bottom: 50.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kPaletteBorderColor),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text("お届け先",
                style: TextStyle(
                  fontSize: 20,
                  color: paletteBlackColor,
                  fontWeight: FontWeight.w600,
                )),
          ),
          SizedBox(height: 24.0),
          _buildAddressInputRows(),
          SizedBox(height: 24.0),
          _buildPhoneNumberInputRow(),
        ],
      ),
    );
  }

  Widget _buildAddressInputRows() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 8.0),
          child: Text("住所",
              style: TextStyle(
                fontSize: 16.0,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              )),
        ),
        SizedBox(width: 16.0),
        Container(
          padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          height: 160.0,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: paletteGreyColor4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPostcodeInputRow(),
              _buildPrefectureInputRow(),
              _buildMunicipalityInputRow(),
              _buildBuildingNameInputRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostcodeInputRow() {
    return Container(
      width: 245.0,
      child: Row(
        children: <Widget>[
          Text("〒",
              style: TextStyle(
                fontSize: 16.0,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              )),
          SizedBox(width: 4.0),
          Container(
            width: 100.0,
            height: 30.0,
            child: TextField(
              controller: postcodeTextController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '郵便番号',
                contentPadding:
                    EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
              ),
            ),
          ),
          SizedBox(width: 20.0),
          _buildSearchByPostcodeButton(),
        ],
      ),
    );
  }

  Widget _buildSearchByPostcodeButton() {
    return Container(
      height: 35.0,
      child: FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        color: paletteRoseColor,
        child: Text(
          "郵便番号から検索",
          style: TextStyle(
            fontSize: 12.0,
            color: paletteBlackColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        onPressed: () async {
          // TODO get address from JP postcode
        },
      ),
    );
  }

  Widget _buildPrefectureInputRow() {
    return Container(
      height: 30.0,
      width: 120.0,
      child: TextField(
        controller: prefectureTextController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
          hintText: '都道府県',
        ),
      ),
    );
  }

  Widget _buildMunicipalityInputRow() {
    return Container(
      height: 30.0,
      width: 245.0,
      child: TextField(
        controller: municipalityTextController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
          hintText: '市区町村',
        ),
      ),
    );
  }

  Widget _buildBuildingNameInputRow() {
    return Container(
      height: 30.0,
      width: 245.0,
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: buildingNameTextController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
          hintText: '建物名など',
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInputRow() {
    return Row(
      children: <Widget>[
        Container(
          child: Text("電話",
              style: TextStyle(
                fontSize: 16.0,
                color: paletteBlackColor,
                fontWeight: FontWeight.w300,
              )),
        ),
        SizedBox(width: 16.0),
        Container(
          padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: paletteGreyColor4),
            ),
          ),
          child: Container(
            height: 30.0,
            width: 245.0,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value.isEmpty) {
                  return '電話が入力されていません';
                }
                return null;
              },
              controller: phoneNumberTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.only(left: 14.0, top: 0.0, bottom: 0.0),
                hintText: '000-0000-0000',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

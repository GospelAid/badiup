import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

class ShippingAddressInputForm extends StatefulWidget {
  ShippingAddressInputForm({
    this.postcodeTextController,
    this.prefectureTextController,
    this.municipalityTextController,
    this.buildingNameTextController,
    this.phoneNumberTextController,
  });

  final TextEditingController postcodeTextController;
  final TextEditingController prefectureTextController;
  final TextEditingController municipalityTextController;
  final TextEditingController buildingNameTextController;
  final TextEditingController phoneNumberTextController;

  @override
  _ShippingAddressInputFormState createState() =>
      _ShippingAddressInputFormState();
}

class _ShippingAddressInputFormState extends State<ShippingAddressInputForm> {
  String _selectedPrefecture = "愛知県";

  @override
  void initState() {
    super.initState();
    widget.prefectureTextController.text = _selectedPrefecture;
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
              controller: widget.postcodeTextController,
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
      child: DropdownButton<String>(
        value: _selectedPrefecture,
        underline: Container(height: 0),
        icon: Icon(Icons.keyboard_arrow_down, color: paletteBlackColor),
        onChanged: (String newValue) {
          setState(() {
            _selectedPrefecture = newValue;
            widget.prefectureTextController.text = newValue;
          });
        },
        items: [
          "愛知県",
          "秋田県",
          "青森県",
          "千葉県",
          "愛媛県",
          "福井県",
          "福岡県",
          "福島県",
          "岐阜県",
          "群馬県",
          "広島県",
          "北海道",
          "兵庫県",
          "茨城県",
          "石川県",
          "岩手県",
          "香川県",
          "鹿児島県",
          "神奈川県",
          "高知県",
          "熊本県",
          "京都府",
          "三重県",
          "宮城県",
          "宮崎県",
          "長野県",
          "長崎県",
          "奈良県",
          "新潟県",
          "大分県",
          "岡山県",
          "沖縄県",
          "大阪府",
          "佐賀県",
          "埼玉県",
          "滋賀県",
          "島根県",
          "静岡県",
          "栃木県",
          "徳島県",
          "東京都",
          "鳥取県",
          "富山県",
          "和歌山県",
          "山形県",
          "山口県",
          "山梨県",
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMunicipalityInputRow() {
    return Container(
      height: 30.0,
      width: 245.0,
      child: TextField(
        controller: widget.municipalityTextController,
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
        controller: widget.buildingNameTextController,
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
              controller: widget.phoneNumberTextController,
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

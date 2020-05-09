import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:badiup/colors.dart';
import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/custom_color_model.dart';

class AdminNewColorPage extends StatefulWidget {
  @override
  _NewColorPageState createState() {
    return _NewColorPageState();
  }
}

class _NewColorPageState extends State<AdminNewColorPage> {
  final _nameEditingController = TextEditingController();
  final _labelEditingController = TextEditingController();
  Color _currentColor = Colors.white;
  String _selectedTextColor = "grey";

  void changeColor(Color color) => setState(() => _currentColor = color);
  String extractHexFromColor(Color color) =>
      color.toString().split('(')[1].split(')')[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('色の追加'),
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    var widgetList = <Widget>[
      _buildColorListFromDB(context),
      _buildNameTextField(),
      _buildLabelTextField(),
      _buildTextColorDropdown(),
      _buildHexButtonField(),
      _buildSubmitButton(),
    ];

    return Stack(
      children: widgetList,
    );
  }

  Widget _buildNameTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
      child: TextFormField(
        controller: _nameEditingController,
        decoration: InputDecoration(
          labelText: 'Name',
        ),
        maxLength: 10,
        validator: (value) {
          if (value.isEmpty) {
            return 'Nameが入力されていません';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildHexButtonField() {
    var _textStyle = TextStyle(
      color: _currentColor,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 180.0, 16.0, 0.0),
        child: Row(children: <Widget>[
          RaisedButton(
            elevation: 3.0,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: _currentColor,
                        onColorChanged: changeColor,
                        colorPickerWidth: 300.0,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: true,
                        displayThumbColor: true,
                        showLabel: true,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Text("色を選択"),
            color: _currentColor,
            textColor: useWhiteForeground(_currentColor)
                ? const Color(0xffffffff)
                : const Color(0xff000000),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text(extractHexFromColor(_currentColor), style: _textStyle))
        ]));
  }

  Widget _buildLabelTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 60.0),
      child: TextFormField(
        controller: _labelEditingController,
        decoration: InputDecoration(
          labelText: 'Label',
        ),
        maxLength: 10,
        validator: (value) {
          if (value.isEmpty) {
            return 'Labelが入力されていません';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextColorDropdown() {
    var _textStyle = TextStyle(
      color: paletteBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    List<String> _items = ["grey", "white"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 250.0, 16.0, 60.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Text Color",
              style: TextStyle(
                color: paletteBlackColor,
                fontSize: 20
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedTextColor,
              icon: Icon(Icons.keyboard_arrow_down, color: paletteBlackColor),
              iconSize: 32,
              elevation: 2,
              style: _textStyle,
              underline: Container(height: 0, color: paletteBlackColor),
              onChanged: (String newValue) {
                setState(() {
                  _selectedTextColor = newValue;
                });
              },
              items: _items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: item == _selectedTextColor
                        ? TextStyle(fontWeight: FontWeight.bold)
                        : TextStyle(fontWeight: FontWeight.normal),
                  ),
                );
              }).toList(),
            ),
          ]),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 330.0, 16.0, 60.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        onPressed: () async {
          //TODO: Add validation to all form components
          await _submitForm();
          _nameEditingController.clear();
          _labelEditingController.clear();
          changeColor(Color(0xffffffff));
          setState(() {
            _selectedTextColor = "grey";
          });
          Navigator.pop(context);
        },
        child: Text('追加する'),
      ),
    );
  }

  CustomColor _buildColorModel() {
    final _color = CustomColor(
      name: _nameEditingController.text,
      hex: extractHexFromColor(_currentColor),
      label: _labelEditingController.text,
      textColor: _selectedTextColor,
    );
    return _color;
  }

  Future<void> _submitForm() async {
    CustomColor _colorModel = _buildColorModel();
    await Firestore.instance
        .collection(constants.DBCollections.colors)
        .add(_colorModel.toMap());
  }

  Widget _buildColorListFromDB(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(constants.DBCollections.colors)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 400.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final color = CustomColor.fromSnapshot(data);
    var textColorStyle = color.textColor == "grey"
        ? TextStyle(color: paletteGreyColor2)
        : TextStyle(color: kPaletteWhite);

    return Padding(
      key: ValueKey(color.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          leading: Text(color.name, style: getTextStyleWithHex(color.hex)),
          title: Text(color.label, style: getTextStyleWithHex(color.hex)),
          subtitle: Text(color.hex, style: getTextStyleWithHex(color.hex)),
          trailing: Text(color.textColor, style: textColorStyle),
        ),
      ),
    );
  }
}

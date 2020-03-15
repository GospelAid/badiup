import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

class QuantityController extends ValueNotifier<int> {
  QuantityController({int value}) : super(value);

  int get quantity => value;

  set quantity(int newValue) {
    value = newValue;
  }
}

class QuantitySelector extends StatefulWidget {
  QuantitySelector({
    Key key,
    this.controller,
    this.orientation,
    this.iconSize = 24.0,
  })  : assert(controller != null),
        assert(orientation != null),
        super(key: key);

  final QuantityController controller;
  final Orientation orientation;
  final double iconSize;

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  double buttonIconSize;
  double buttonSize;

  @override
  void initState() {
    buttonIconSize = 0.875 * widget.iconSize;
    buttonSize = widget.iconSize;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int itemsCounterValue = widget.controller.value;
    String stopQuantityText = '在庫不足です';
    List<Widget> widgetList = widget.orientation == Orientation.landscape
        ? <Widget>[
            _buildDecreaseQuantityButton(),
            _buildQuantityDisplay(),
            _buildIncreaseQuantityButton(),
          ]
        : <Widget>[
            _buildIncreaseQuantityButton(),
            _buildQuantityDisplay(),
            _buildDecreaseQuantityButton(),
          ];
    List<Widget> widgetList2 = new List<Widget>();
    widgetList2.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgetList,
      ),
    );
    if (itemsCounterValue == 10)
      widgetList2.add(Text(
        stopQuantityText,
        style: TextStyle(
          color: paletteForegroundColor,
          fontSize: 0.4 * widget.iconSize,
        ),
      ));
    return Padding(
      padding: EdgeInsets.all(0),
      child: widget.orientation == Orientation.landscape
          ? Column(
              children: widgetList2,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgetList,
            ),
    );
  }

  Widget _buildQuantityDisplay() {
    double shortSideSize = widget.iconSize;
    double longSideSize = 2 * shortSideSize;

    return Container(
      alignment: AlignmentDirectional.center,
      color: kPaletteWhite,
      height: widget.orientation == Orientation.landscape
          ? shortSideSize
          : longSideSize,
      width: widget.orientation == Orientation.landscape
          ? longSideSize
          : shortSideSize,
      child: Text(
        widget.controller.value.toString(),
        style: TextStyle(
          color: paletteBlackColor,
          fontWeight: FontWeight.bold,
          fontSize: 0.625 * widget.iconSize,
        ),
      ),
    );
  }

  Widget _buildIncreaseQuantityButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.controller.value < 10) widget.controller.value++;
        });
      },
      child: _buildIncreaseQuantityButtonVisuals(),
    );
  }

  Widget _buildIncreaseQuantityButtonVisuals() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: buttonSize,
          width: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: widget.controller.value == 10
                ? paletteDarkGreyColor
                : paletteForegroundColor,
            borderRadius: widget.orientation == Orientation.landscape
                ? BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
          ),
        ),
        Icon(
          Icons.add,
          color: kPaletteWhite,
          size: buttonIconSize,
        ),
      ],
    );
  }

  Widget _buildDecreaseQuantityButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.controller.value =
              widget.controller.value <= 1 ? 1 : widget.controller.value - 1;
        });
      },
      child: _buildDecreaseQuantityButtonVisuals(),
    );
  }

  Widget _buildDecreaseQuantityButtonVisuals() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: buttonSize,
          width: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: widget.controller.value == 1
                ? paletteDarkGreyColor
                : paletteBlackColor,
            borderRadius: widget.orientation == Orientation.landscape
                ? BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  )
                : BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
          ),
        ),
        Icon(
          Icons.remove,
          color: kPaletteWhite,
          size: buttonIconSize,
        ),
      ],
    );
  }
}

import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

enum ItemColor {
  black,
  brown,
  na,
  white,
}

enum ItemSize {
  large,
  medium,
  na,
  small,
}

String getDisplayTextForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.black:
      return "ブラック";
    case ItemColor.brown:
      return "ブラウン";
    case ItemColor.na:
      return "無し";
    case ItemColor.white:
      return "ホワイト";
    default:
      return "";
  }
}

Color getDisplayColorForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.black:
      return paletteBlackColor;
    case ItemColor.brown:
      return paletteBrownColor;
    case ItemColor.na:
      return Colors.transparent;
    case ItemColor.white:
      return kPaletteWhite;
    default:
      return Colors.transparent;
  }
}

Color getDisplayTextColorForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.black:
      return kPaletteWhite;
    case ItemColor.brown:
      return kPaletteWhite;
    case ItemColor.na:
      return paletteGreyColor2;
    case ItemColor.white:
      return paletteGreyColor2;
    default:
      return paletteGreyColor2;
  }
}

String getDisplayTextForItemSize(ItemSize itemSize) {
  switch (itemSize) {
    case ItemSize.large:
      return "L";
    case ItemSize.medium:
      return "M";
    case ItemSize.na:
      return "x";
    case ItemSize.small:
      return "S";
    default:
      return "";
  }
}

class StockIdentifier {
  final ItemColor color;
  final ItemSize size;

  StockIdentifier({
    this.color,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color.index,
      'size': size.index,
    };
  }

  StockIdentifier.fromMap(Map<String, dynamic> map)
      : assert(map['color'] != null),
        assert(map['size'] != null),
        color = ItemColor.values[map['color']],
        size = ItemSize.values[map['size']];
}

class Stock {
  final StockIdentifier identifier;
  final int quantity;

  Stock({
    this.identifier,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier.toMap(),
      'quantity': quantity,
    };
  }

  Stock.fromMap(Map<String, dynamic> map)
      : identifier = StockIdentifier.fromMap(
          map['identifier'].cast<String, dynamic>(),
        ),
        quantity = map['quantity'];
}

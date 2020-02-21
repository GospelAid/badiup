import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

enum ItemColor {
  black,
  brown,
  white,
}

enum ItemSize {
  large,
  medium,
  small,
}

enum StockType {
  sizeAndColor,
  sizeOnly,
  colorOnly,
}

String getDisplayTextForStockType(StockType stockType) {
  switch (stockType) {
    case StockType.colorOnly:
      return "色のみ選択";
    case StockType.sizeAndColor:
      return "サイズと色を選択";
    case StockType.sizeOnly:
      return "サイズのみ選択";
    default:
      return "";
  }
}

String getDisplayTextForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.black:
      return "ブラック";
    case ItemColor.brown:
      return "ブラウン";
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
    case ItemSize.small:
      return "S";
    default:
      return "";
  }
}

class StockItem {
  final ItemColor color;
  final ItemSize size;
  final int quantity;

  StockItem({
    this.color,
    this.size,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color.index,
      'size': size.index,
      'quantity': quantity,
    };
  }

  StockItem.fromMap(Map<String, dynamic> map)
      : assert(map['color'] != null),
        assert(map['size'] != null),
        color = ItemColor.values[map['color']],
        size = ItemSize.values[map['size']],
        quantity = map['quantity'];
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
  final List<StockItem> items;
  final StockType stockType;

  Stock({
    this.items,
    this.stockType,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items?.map((item) => item.toMap())?.toList(),
      'stockType': stockType.index,
    };
  }

  Stock.fromMap(Map<String, dynamic> map)
      : items = map['items']
            ?.map<StockItem>(
                (stock) => StockItem.fromMap(stock.cast<String, dynamic>()))
            ?.toList(),
        stockType = StockType.values[map['stockType']];
}

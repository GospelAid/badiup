import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

enum ItemColor {
  black,
  brown,
  white,
  pink,
  grey,
}

enum ItemSize {
  large3,
  large2,
  large,
  medium,
  small,
  extraSmall,
}

enum StockType {
  sizeAndColor,
  sizeOnly,
  colorOnly,
  quantityOnly,
}

String getDisplayTextForStockType(StockType stockType) {
  switch (stockType) {
    case StockType.colorOnly:
      return "色のみ選択";
    case StockType.sizeAndColor:
      return "サイズと色を選択";
    case StockType.sizeOnly:
      return "サイズのみ選択";
    case StockType.quantityOnly:
      return "在庫数のみを選択";
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
    case ItemColor.pink:
      return "ピンク";
    case ItemColor.grey:
      return "グレー";
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
    case ItemColor.pink:
      return kPalettePurple100;
    case ItemColor.grey:
      return paletteGreyColor;
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
    case ItemColor.pink:
      return kPaletteWhite; 
    case ItemColor.grey:
      return kPaletteWhite;
    default:
      return paletteGreyColor2;
  }
}

String getDisplayTextForItemSize(ItemSize itemSize) {
  switch (itemSize) {
    case ItemSize.large3:
      return "3L";
    case ItemSize.large2:
      return "2L";
    case ItemSize.large:
      return "L";
    case ItemSize.medium:
      return "M";
    case ItemSize.small:
      return "S";
    case ItemSize.extraSmall:
      return "XS";
    default:
      return "";
  }
}

class StockItem {
  final ItemColor color;
  final ItemSize size;
  int quantity;

  StockItem({
    this.color,
    this.size,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color?.index,
      'size': size?.index,
      'quantity': quantity,
    };
  }

  StockItem.fromMap(Map<String, dynamic> map)
      : color = map['color'] != null ? ItemColor.values[map['color']] : null,
        size = map['size'] != null ? ItemSize.values[map['size']] : null,
        quantity = map['quantity'];
}

class StockIdentifier {
  final ItemColor color;
  final ItemSize size;

  StockIdentifier({
    this.color,
    this.size,
  });
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

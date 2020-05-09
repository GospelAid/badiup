import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

//TOREMOVE: remove ItemColor once custom color model is integrated in both admin and customer pages. 
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

//TOREMOVE: remove getDisplayTextForItemColor once custom color model is integrated in both admin and customer pages. 
String getDisplayTextForItemColor(String colorName) {
  switch (colorName) {
    case "black":
      return "ブラック";
    case "brown":
      return "ブラウン";
    case "white":
      return "ホワイト";
    case "pink":
      return "ピンク";
    case "grey":
      return "グレー";
    default:
      return "";
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
  final String color;
  final ItemSize size;
  int quantity;

  StockItem({
    this.color,
    this.size,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'size': size?.index,
      'quantity': quantity,
    };
  }

  // TOREMOVE: Update color value type from int to String in order's stock item in Firestore first then remove this indexColorMap
  static Map indexColorMap = {
    "0": "black",
    "1": "brown",
    "2": "white",
    "3": "pink",
    "4": "grey",
  };

  StockItem.fromMap(Map<String, dynamic> map)
    // TOREMOVE: Remove "map['color'] is int" condition once color value type gets updated from int to String in order's stock item in Firestore
      : color = map['color'] is int 
        ? indexColorMap[map['color'].toString()] : map['color'] is String ? map['color'] : null,
        size = map['size'] != null ? ItemSize.values[map['size']] : null,
        quantity = map['quantity'];
}

class StockIdentifier {
  final String color;
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

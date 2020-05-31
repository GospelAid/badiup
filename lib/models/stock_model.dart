import 'package:badiup/colors.dart';
import 'package:flutter/material.dart';

enum ItemColor {
  blackKana,
  brown,
  whiteKana,
  pink,
  grey,
  whiteWithCamelBeads,
  whiteAndWhiteBeads,
  blackWithBlackBeads,
  camel,
  whiteKanji,
  blackKanji,
  yellow,
  purple,
}

enum ItemSize {
  ladiesLarge,
  ladiesMedium,
  ladiesSmall,
  mens3xl,
  mensXxl,
  mensXl,
  mensLarge,
  mensMedium,
  mensSmall,
  singleItem,
  fiveItemPack,
  tenItemPack,
  oneCup,
  fiveCups,
  tenCups,
  twentyCups,
  thirtyFiveCups,
  seventyCups,
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
      return "色のみ";
    case StockType.sizeAndColor:
      return "サイズと色";
    case StockType.sizeOnly:
      return "サイズのみ";
    case StockType.quantityOnly:
      return "在庫数のみ";
    default:
      return "";
  }
}

String getDisplayTextForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.blackKana:
      return "ブラック";
    case ItemColor.blackKanji:
      return "黒";
    case ItemColor.brown:
      return "ブラウン";
    case ItemColor.whiteKana:
      return "ホワイト";
    case ItemColor.whiteKanji:
      return "白";
    case ItemColor.pink:
      return "ピンク";
    case ItemColor.grey:
      return "グレー";
    case ItemColor.whiteWithCamelBeads:
      return "白×キャメルビーズ";
    case ItemColor.whiteAndWhiteBeads:
      return "白×白ビーズ";
    case ItemColor.blackWithBlackBeads:
      return "黒×黒ビーズ";
    case ItemColor.camel:
      return "キャメル";
    case ItemColor.yellow:
      return "黄";
    case ItemColor.purple:
      return "紫";
    default:
      return "";
  }
}

Color getDisplayColorForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.blackKana:
    case ItemColor.blackKanji:
    case ItemColor.blackWithBlackBeads:
      return paletteBlackColor;
    case ItemColor.brown:
      return paletteBrownColor;
    case ItemColor.camel:
      return const Color(0xFFC19A6B);
    case ItemColor.whiteKana:
    case ItemColor.whiteKanji:
    case ItemColor.whiteAndWhiteBeads:
    case ItemColor.whiteWithCamelBeads:
      return kPaletteWhite;
    case ItemColor.pink:
      return kPalettePurple100;
    case ItemColor.grey:
      return paletteGreyColor;
    case ItemColor.yellow:
      return Colors.yellow;
    case ItemColor.purple:
      return Colors.purple;
    default:
      return Colors.transparent;
  }
}

Color getDisplayTextColorForItemColor(ItemColor itemColor) {
  switch (itemColor) {
    case ItemColor.blackKana:
    case ItemColor.blackKanji:
    case ItemColor.blackWithBlackBeads:
    case ItemColor.brown:
    case ItemColor.pink:
    case ItemColor.grey:
    case ItemColor.camel:
    case ItemColor.purple:
      return kPaletteWhite;
    case ItemColor.whiteKana:
    case ItemColor.whiteKanji:
    case ItemColor.whiteWithCamelBeads:
    case ItemColor.whiteAndWhiteBeads:
      return paletteGreyColor2;
    default:
      return paletteGreyColor2;
  }
}

String getDisplayTextForItemSize(ItemSize itemSize) {
  switch (itemSize) {
    case ItemSize.ladiesSmall:
      return "レディース S";
    case ItemSize.ladiesMedium:
      return "レディース M";
    case ItemSize.ladiesLarge:
      return "レディース L";
    case ItemSize.mensSmall:
      return "メンズ S";
    case ItemSize.mensMedium:
      return "メンズ M";
    case ItemSize.mensLarge:
      return "メンズ L";
    case ItemSize.mensXl:
      return "メンズ XL";
    case ItemSize.mensXxl:
      return "メンズ XXL";
    case ItemSize.mens3xl:
      return "メンズ 3XL";
    case ItemSize.singleItem:
      return "一個";
    case ItemSize.fiveItemPack:
      return "5個";
    case ItemSize.tenItemPack:
      return "贈答用箱入り10個";
    case ItemSize.oneCup:
      return "一杯";
    case ItemSize.fiveCups:
      return "5杯";
    case ItemSize.tenCups:
      return "10杯";
    case ItemSize.twentyCups:
      return "20杯";
    case ItemSize.thirtyFiveCups:
      return "35杯";
    case ItemSize.seventyCups:
      return "70杯";
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

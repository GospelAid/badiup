enum DeliveryMethod {
  japanPost,
  sagawa,
}

String getDisplayTextForDeliveryMethod(DeliveryMethod deliveryMethod) {
  switch (deliveryMethod) {
    case DeliveryMethod.japanPost:
      return "ゆうパック";
    case DeliveryMethod.sagawa:
      return "宅急便";
    default:
      return "";
  }
}

class TrackingDetails {
  DeliveryMethod deliveryMethod;
  String code;

  TrackingDetails({
    this.deliveryMethod,
    this.code,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'deliveryMethod': deliveryMethod.index,
      'code': code,
    };

    return map;
  }

  TrackingDetails.fromMap(Map<String, dynamic> map)
      : deliveryMethod = DeliveryMethod.values[map['deliveryMethod']],
        code = map['code'];
}

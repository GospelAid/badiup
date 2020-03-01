class UserSetting {
  final bool pushNotifications;
  bool taxInclusive;

  UserSetting({
    this.pushNotifications,
    this.taxInclusive,
  });

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'taxInclusive': taxInclusive,
    };
  }

  UserSetting.fromMap(Map<String, dynamic> map)
    : assert(map['pushNotifications'] != null),
      pushNotifications = map['pushNotifications'],
      taxInclusive = map ['taxInclusive'];
}

class UserSetting {
  bool pushNotifications;

  UserSetting({
    this.pushNotifications,
  });

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
    };
  }

  UserSetting.fromMap(Map<String, dynamic> map)
    : assert(map['pushNotifications'] != null),
      pushNotifications = map['pushNotifications'];
}

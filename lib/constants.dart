library constants;

const double imageHeight = 210;

// Database Collections
class DBCollections {
  static const String users = 'users';
  static const String products = "products";
  static const String orders = "orders";
  static const String texts = "texts";
  static const String colors = "colors";
}

class StorageCollections {
  static const String products = "products";
  static const String images = "images";
}

class SharedPrefsKeys {
  static const String appOpenedFirstTime = "appOpenedFirstTime";
}

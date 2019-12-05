enum TKUsers {
  user,
  customer,
  admin,
}

enum TKScreens {
  login,
  home,
  drawer,
  productListing,
  addProduct,
  editProduct,
  productDetail,
  gallery,
}

String makeTestKeyString(TKUsers user, TKScreens screen, String keyword) {
  return user.toString() + screen.toString() + keyword;
}

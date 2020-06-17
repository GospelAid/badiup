import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/admin_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final db = Firestore.instance;
User currentSignedInUser = User();

Future<bool> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount == null) {
    return false;
  }

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  AuthResult authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (authResult.user == null) {
    return false;
  }

  await _addUserToDatabase(authResult);

  return true;
}

Future _addUserToDatabase(AuthResult authResult) async {
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  assert(user.uid == currentUser.uid);

  // check if user already exists
  final DocumentSnapshot userSnapshot = await db
      .collection(constants.DBCollections.users)
      .document(user.email)
      .get();

  if (userSnapshot.exists) {
    // user exists, retrieve user data from firestore
    updateCurrentSignedInUser(userSnapshot);
  } else {
    // user not exists, create a new user
    await addUserToFirestore(user: user);
  }
}

Future<bool> signInWithApple() async {
  final AuthorizationResult result = await AppleSignIn.performRequests([
    AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  ]);

  if (result.status != AuthorizationStatus.authorized) {
    return false;
  }

  final AppleIdCredential appleIdCredential = result.credential;

  OAuthProvider oAuthProvider = new OAuthProvider(providerId: 'apple.com');
  final AuthCredential credential = oAuthProvider.getCredential(
    idToken: String.fromCharCodes(appleIdCredential.identityToken),
    accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
  );

  final AuthResult authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (authResult.user == null) {
    return false;
  }

  await _addUserToDatabase(authResult);

  return true;
}

void signOutGoogle() async {
  currentSignedInUser = User();
  await googleSignIn.signOut();
  print('user signed out');
}

// retrieve user data from Firestore
void updateCurrentSignedInUser(DocumentSnapshot userSnapshot) {
  switch (User.fromSnapshot(userSnapshot).role) {
    case RoleType.admin:
      currentSignedInUser = Admin.fromSnapshot(userSnapshot);
      break;
    case RoleType.customer:
      currentSignedInUser = Customer.fromSnapshot(userSnapshot);
      break;
    default:
      break;
  }
}

// add user to firestore, email as document ID
Future<void> addUserToFirestore({FirebaseUser user}) async {
  // add user to firestore, email as document ID
  currentSignedInUser = Customer(
    email: user.email,
    name: user.displayName ?? '',
    role: RoleType.customer, // add user as customer by default
    setting: UserSetting(pushNotifications: true, taxInclusive: true),
    shippingAddresses: List<Address>(),
    created: DateTime.now().toUtc(),
  );
  await db
      .collection(constants.DBCollections.users)
      .document(user.email)
      .setData(currentSignedInUser.toMap());
}

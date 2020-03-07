import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:badiup/constants.dart' as constants;
import 'package:badiup/models/address_model.dart';
import 'package:badiup/models/admin_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/models/user_setting_model.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final db = Firestore.instance;
User currentSignedInUser = User();

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount == null) {
    return null;
  }

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
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

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async {
  await db
      .collection(constants.DBCollections.users)
      .document(currentSignedInUser.email)
      .updateData({'timesOfSignIn': currentSignedInUser.timesOfSignIn + 1});
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
    name: user.displayName,
    role: RoleType.customer, // add user as customer by default
    setting: UserSetting(pushNotifications: true, taxInclusive: true),
    shippingAddresses: List<Address>(),
    created: DateTime.now().toUtc(),
    timesOfSignIn: 0,
  );
  await db
      .collection(constants.DBCollections.users)
      .document(user.email)
      .setData(currentSignedInUser.toMap());
}

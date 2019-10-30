import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/user_setting_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/constants.dart' as Constants;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final db = Firestore.instance;
Customer currentSignedInUser;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
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
  DocumentSnapshot userSnapshot = await db.collection(Constants.DBCollections.customers).document(user.email).get();
  if ( userSnapshot.exists ) {
    // user exists, retrieve user data from firestore
    currentSignedInUser = Customer.fromSnapshot(userSnapshot);
  } else {
    // user not exists, create a new user
    await addUserToFirestore( user: user );
  }
  // add user to firestore, email as document ID
  

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  currentSignedInUser = Customer();
  await googleSignIn.signOut();
  print('user signed out');
}


// add user to firestore, email as document ID
Future<void> addUserToFirestore({ FirebaseUser user }) async {
  // add one usersetting
  final DocumentReference userSettingReference = 
    await db.collection(Constants.DBCollections.userSettings).add( 
      UserSetting(pushNotifications: true).toMap()
    );
  // TODO: add one default shipping address ?
  // TODO: add addresses list ?

  // add user to firestore, email as document ID
  currentSignedInUser = Customer(
    email: user.email,
    name: user.displayName,
    role: RoleType.customer, // add user as customer by default
    setting: userSettingReference,
    created: DateTime.now().toUtc(),
  );
  await db.collection(Constants.DBCollections.customers).document(user.email).setData(
    currentSignedInUser.toMap()
  );
}

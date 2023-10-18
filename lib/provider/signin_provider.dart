import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookAuth facebookSignIn = FacebookAuth.instance;
  

  bool _isSignIn = false;
  bool get isSignIn => _isSignIn;
  
  bool _hasError = false;
  bool get hasError => _hasError;
  
  String? _errorCode;
  String? get errorCode => _errorCode;
  
  String? _provider;
  String? get provider => _provider;
  
  String? uID;
  String? get userID => uID;
  
  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? imageUrl;
  String? get image => imageUrl;

  SignInProvider() {
    checkSignInUser();
  }
  Future checkSignInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignIn = prefs.getBool('signed_in') ?? false;
    notifyListeners();
  }

  Future signInwithGoogle() async {
   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
   if(GoogleSignInAccount != null){
    try{
      final GoogleSignInAuthentication googleSignInAuthentication = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final User userDetail = (await firebaseAuth.signInWithCredential(credential)).user!;
      userDetail.providerData.forEach((element) {
        _provider = element.providerId;
        _name = element.displayName;
        _email = element.email;
        imageUrl = element.photoURL;
        uID = element.uid;
        notifyListeners();
      });
    }on FirebaseAuthException catch(e){
     switch(e.code){
      case "account-exists-with-different-credential":
      _errorCode = "The account already exists with a different credential";
      _hasError = true;
      notifyListeners();
      break;
      case "null":
      _errorCode = "An undefined Error happened";
      _hasError = true;
      notifyListeners();
      break;
      default:
      _errorCode = e.toString();
      _hasError = true;
      notifyListeners();
     }
    }
   }
   else{
    _hasError =true;
    notifyListeners();
   }
  } 

  Future<bool> checkUserExist() async{
  DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(uID).get();
  if(snap.exists){
    print("Existing User");
    return true;
  }
  else{
    print("New User");
    return false;
  }

  }
  Future getDataFromSP() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    imageUrl = prefs.getString('image_url');
    _provider = prefs.getString('provider');
    uID = prefs.getString('uid');
    notifyListeners();
  }

Future getUserDataFromFirestore(uID) async{
  await FirebaseFirestore.instance.collection('users').doc(uID).get().then((DocumentSnapshot value) {
    _name = value['name'];
    _email = value['email'];
    imageUrl = value['image_url'];
    _provider = value['provider'];
    uID =value['uid'];
    notifyListeners();
  });
}
Future saveDataToFirestore() async{
  final DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(uID);
  await documentReference.set(
    {
      'name': _name,
      'email': _email,
      'image_url': imageUrl,
      'provider': _provider,
      'uid': uID,
    });
  notifyListeners();
}

  Future userSignout() async{
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    _isSignIn = false;
    notifyListeners();
    clearSharedData();
  }
  Future clearSharedData() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  } 
  Future saveDataToSharePrefference() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name!);
    prefs.setString('email', _email!);
    prefs.setString('image_url', imageUrl!);
    prefs.setString('provider', _provider!);
    prefs.setString('uid', uID!);
    notifyListeners();
  } 
  Future setSignIn() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('signed_in', true);
    _isSignIn = true;
    notifyListeners();
  }
 Future signInWithFacebook() async {
    final LoginResult result = await facebookSignIn.login();
    // getting the profile
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

    final profile = jsonDecode(graphResponse.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        // saving the values
        _name = profile['name'];
        _email = profile['email'];
        imageUrl = profile['picture']['data']['url'];
        uID = profile['id'];
        _hasError = false;
        _provider = "FACEBOOK";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  saveDataToSharedPreferences() {}
}
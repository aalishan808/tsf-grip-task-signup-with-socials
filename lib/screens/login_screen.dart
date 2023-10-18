import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:socialloginapp/provider/internet_provider.dart';
import 'package:socialloginapp/provider/signin_provider.dart';
import 'package:socialloginapp/screens/home_screen.dart';
import 'package:socialloginapp/utils/nextScreen.dart';
import 'package:socialloginapp/utils/snakbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RoundedLoadingButtonController googlecontroller = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookcontroller = RoundedLoadingButtonController();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     key: _scaffoldKey,
     backgroundColor: Colors.white,
      body: SafeArea(child:
      Padding(padding: const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
      child: Column(children: [
        Flexible(
          flex: 2,
          child: Column(children: [
             Text("Welcome to Login Screen", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      
        ],)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedLoadingButton(
              width: MediaQuery.of(context).size.width*0.8,
              elevation: 0,
              borderRadius: 25,
              controller: googlecontroller,
            successColor: Colors.green, 
            onPressed: handleGoogleSignIn,
            child: Wrap(
              children: [
                Icon(
                  FontAwesomeIcons.google,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 15,),
                Text("Sign in with Google", 
                style: TextStyle(color: Colors.white, fontSize: 20),)
              ],
            ),
            color: Colors.red,),
            SizedBox(height: 20,),
            
            RoundedLoadingButton(
              width: MediaQuery.of(context).size.width*0.8,
              elevation: 0,
              borderRadius: 25,
              controller: facebookcontroller,
            successColor: Colors.green, 
            onPressed: handleFacebookAuth,
            child: Wrap(
              children: [
                Icon(
                  FontAwesomeIcons.facebook,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 15,),
                Text("Sign in with Facebook", 
                style: TextStyle(color: Colors.white, fontSize: 20),)
              ],
            ),
            color: Colors.blue,),
             
          
          ],
        )

      ]),
      )
      ),
     
     );
  }
  Future handleGoogleSignIn() async{
    final sp= context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    
    if(ip.hasInternet == false){
       openSnackbar(context,"Check your Internet connection", Colors.red);
      googlecontroller.reset();
    }
    else{
      await sp.signInwithGoogle().then((value) {
        if(sp.hasError){
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
        }
        else{
          //checking if user exist or not
          sp.checkUserExist().then((value) async{
            if(value == true){
              await sp.getUserDataFromFirestore(sp.uID).then((value) => sp.saveDataToSharePrefference().then((value) => sp.setSignIn().then((value){
                googlecontroller.success();

                HandleAfterSignIn();
              
              })));
            }
            else{
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharePrefference().then((value) => sp.setSignIn().then((value){
                googlecontroller.success();
                HandleAfterSignIn();
              })));
            }
          });
        }
      });
    }
  }
   Future handleFacebookAuth() async{
    final sp= context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    
    if(ip.hasInternet == false){  
       openSnackbar(context,"Check your Internet connection", Colors.red);
      facebookcontroller.reset();
    }
    else{
      await sp.signInWithFacebook().then((value) {
        if(sp.hasError){
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
        }
        else{
          //checking if user exist or not
          sp.checkUserExist().then((value) async{
            if(value == true){
              await sp.getUserDataFromFirestore(sp.uID).then((value) => sp.saveDataToSharePrefference().then((value) => sp.setSignIn().then((value){
                facebookcontroller.success();
                HandleAfterSignIn();
              
              })));
            }
            else{
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharePrefference().then((value) => sp.setSignIn().then((value){
                facebookcontroller.success();
                HandleAfterSignIn();
              })));
            }
          });
        }
      });
    }
  }
  //handle after sign in
  HandleAfterSignIn(){
  Future.delayed(const Duration(seconds: 5), () {
    nextScreenReplace(context, const HomeScreen());
  });
  }
}
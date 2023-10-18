import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialloginapp/provider/signin_provider.dart';
import 'package:socialloginapp/screens/home_screen.dart';
import 'package:socialloginapp/screens/login_screen.dart';
import 'package:socialloginapp/utils/nextScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  //init state
@override
  void initState() {
    final sp= context.read<SignInProvider>();
    super.initState();
    Timer(const Duration(seconds: 3), () {
      sp.isSignIn ==false?nextScreen(context, LoginScreen()):nextScreen(context, HomeScreen());
     });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
        child:Image(image: AssetImage('images/sp.jpg'),
        fit: BoxFit.cover,),
      ),
      ),
      );
  }
}
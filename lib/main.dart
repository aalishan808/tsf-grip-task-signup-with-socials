import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialloginapp/provider/internet_provider.dart';
import 'package:socialloginapp/provider/signin_provider.dart';
import 'package:socialloginapp/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context)=>SignInProvider(),),
        ChangeNotifierProvider(create: (context)=>InternetProvider()),
      ],
      child: const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

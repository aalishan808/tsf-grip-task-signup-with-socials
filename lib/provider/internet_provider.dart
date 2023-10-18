import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider extends ChangeNotifier{
  bool _hasInternet = false;
  bool get hasInternet => _hasInternet;
  InternetProvider(){
    checkInternetConnection();
  }
  Future checkInternetConnection() async{
    var result = await Connectivity().checkConnectivity();
    if(result == ConnectivityResult.none){
      _hasInternet = false;
      notifyListeners();
  }
  else if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi){
    _hasInternet = true;
    notifyListeners();
  
  }
  }
}
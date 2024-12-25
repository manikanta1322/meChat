import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(
          const  SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));
      
      if(APIs.auth.currentUser != null){
          if (kDebugMode) {
            print('\nUser : ${APIs.auth.currentUser}');
          }
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) {
              return const HomeScreen();
            }),
          );
      } else {
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) {
              return const LoginScreen();
            }),
          );
      }
      
     
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mv = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mv.height * .15,
            // right: _isAnimate ? mv.width * .25 : -mv.width * .5,
            right: mv.width * .25,
            width: mv.width * .5,
            child: Image.asset('assets/images/logo.png'),
          ),
          Positioned(
              bottom: mv.height * .15,
              left: mv.width * .05,
              width: mv.width * .9,
              height: mv.height * .07,
              child: const Text(
                'Manikanta Chemiti ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontSize: 16,
                ),
              ))
        ],
      ),
    );
  }
}

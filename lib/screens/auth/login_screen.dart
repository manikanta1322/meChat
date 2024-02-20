import 'package:flutter/material.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        setState(() {
          _isAnimate = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mv = MediaQuery.of(context).size;
    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: mv.height * .15,
            right: _isAnimate ? mv.width * .25 : -mv.width * .5,
            width: mv.width * .5,
            child: Image.asset('images/instagram.png'),
          ),
          Positioned(
            bottom: mv.height * .15,
            left: mv.width * .05,
            width: mv.width * .9,
            height: mv.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 221, 254, 222),
                  shape: StadiumBorder(),
                  elevation: 1),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(),
                  ),
                );
              },
              icon: Image.asset(
                'images/google.png',
                height: mv.height * .03,
              ),
              label: RichText(
                text: const TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    children: [
                      TextSpan(text: 'Sign In with '),
                      TextSpan(
                        text: "Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

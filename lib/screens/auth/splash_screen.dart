import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double>
  _textFadeAnimation; // <-- 1. DECLARED THE NEW ANIMATION

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // This animation controls the slide-up motion
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // <-- 2. DEFINED THE NEW FADE ANIMATION
    // This animation controls the fade-in, using the same interval to sync with the slide
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _navigateToNextScreen() {
    Widget targetScreen =
        (APIs.auth.currentUser != null)
            ? const HomeScreen()
            : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F20),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // This will now be centered and correctly sized.
          FadeTransition(
            opacity: _logoFadeAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Image.asset(
                'assets/images/logo.png',
                // THE FIX: Use width to control the size directly.
                // A value around 45% of the screen width is a good starting point.
                width: mq.width * .45, 
                
                // REMOVE THE 'scale' PROPERTY. It was causing the image to become huge.
                // scale: 0.01, 
              ),
            ),
          ),

          // This part remains correct.
          Positioned(
            bottom: mq.height * .08,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Text(
                  'Manikanta Chemiti ❤️',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
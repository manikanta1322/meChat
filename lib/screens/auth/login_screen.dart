import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui'; // Required for ImageFilter.blur

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/dialogs.dart';
import 'package:we_chat/screens/auth/signupScreen.dart';
import 'package:we_chat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // --- STATE FOR UI & ANIMATIONS ---
  bool _isUIAnimated = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  // ** CHANGED: Controller for mobile number instead of email **
  final _mobileController = TextEditingController(); 
  final _passwordController = TextEditingController();

  late double _blob1X, _blob1Y, _blob2X, _blob2Y;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeBlobs();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isUIAnimated = true);
    });
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _animateBlobs();
    });
  }
  
  void _initializeBlobs() {
    final random = Random();
    _blob1X = random.nextDouble() * 0.6; _blob1Y = random.nextDouble() * 0.6;
    _blob2X = random.nextDouble() * 0.6; _blob2Y = random.nextDouble() * 0.6;
  }
  
  void _animateBlobs() {
    final random = Random();
    if (mounted) {
      setState(() {
        _blob1X = random.nextDouble() * 0.6; _blob1Y = random.nextDouble() * 0.6;
        _blob2X = random.nextDouble() * 0.6; _blob2Y = random.nextDouble() * 0.6;
      });
    }
  }


  @override
  void dispose() {
    // ** CHANGED: Dispose the mobile controller **
    _mobileController.dispose();
    _passwordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // --- CORE LOGIN LOGIC (UPDATED) ---
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Dialogs.showProgressBar(context); // Button already has a loading indicator

      try {
        if (!kIsWeb) {
          final result = await InternetAddress.lookup('google.com');
          if (result.isEmpty || result[0].rawAddress.isEmpty) {
            throw const SocketException('No Internet');
          }
        }

        // ** THE TRANSFORMATION **
        // Convert the mobile number into the same fake email format used at signup
        final fakeEmail = "${_mobileController.text.trim()}@wechat.app";

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: fakeEmail, // Use the fake email
          password: _passwordController.text.trim(),
        );

        // This self-healing part should now work correctly if needed
        if (await APIs.userExists()) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          // This will use the fallback in createUser (email part as name)
          await APIs.createUser(); 
          if (!mounted) return;
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }

      } on SocketException catch (_) {
        if (mounted) Dialogs.showSnackbar(context, 'No Internet Connection');
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          // Provide more user-friendly error messages
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            Dialogs.showSnackbar(context, 'Invalid mobile number or password.');
          } else {
            Dialogs.showSnackbar(context, 'Login Failed: ${e.message}');
          }
        }
      } catch (e) {
        if (mounted) Dialogs.showSnackbar(context, 'Something went wrong: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F20),
      body: Stack(
        children: [
          _buildDynamicBackground(mq),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildGlassmorphicContainer(mq),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildGlassmorphicContainer(Size mq) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      scale: _isUIAnimated ? 1.0 : 0.8,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _isUIAnimated ? 1.0 : 0.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
              ),
              child: _buildForm(mq),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Size mq) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: mq.width * .3),
          const SizedBox(height: 16),
          Text("Welcome Back", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Sign in to your account", style: GoogleFonts.poppins(color: Colors.white70)),
          const SizedBox(height: 32),

          // ** CHANGED: Mobile Number Field **
          TextFormField(
            controller: _mobileController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Mobile Number', Icons.phone_android_outlined),
            validator: (val) => val != null && val.length >= 10
                ? null
                : 'Enter a valid mobile number',
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: _inputDecoration('Password', Icons.lock_outline),
            validator: (val) => val != null && val.length >= 6
                ? null
                : 'Password must be at least 6 characters',
          ),
          const SizedBox(height: 32),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildSignupText(),
        ],
      ),
    );
  }

  // All other UI helper methods are the same and do not need to be changed.
  // I am including them here for a complete, copy-paste ready file.
  
  Widget _buildDynamicBackground(Size mq) { /* Omitted for brevity, include your existing code */ return Stack(children:[AnimatedPositioned(duration:const Duration(seconds:6),curve:Curves.easeInOut,top:mq.height*_blob1Y,left:mq.width*_blob1X,child:_buildBlob(const Color(0xFF00F5D4),250),),AnimatedPositioned(duration:const Duration(seconds:6),curve:Curves.easeInOut,bottom:mq.height*_blob2Y,right:mq.width*_blob2X,child:_buildBlob(const Color(0xFFFC5C7D),300),),]); }
  Widget _buildBlob(Color color,double size) { /* Omitted for brevity, include your existing code */ return Container(width:size,height:size,decoration:BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(colors:[color.withOpacity(0.5),color.withOpacity(0.1)],begin:Alignment.topLeft,end:Alignment.bottomRight,),),); }
  InputDecoration _inputDecoration(String label,IconData icon) { /* Omitted for brevity, include your existing code */ return InputDecoration(labelText:label,labelStyle:GoogleFonts.poppins(color:Colors.white70),prefixIcon:Icon(icon,color:Colors.white70,size:20),contentPadding:const EdgeInsets.symmetric(vertical:18,horizontal:10),enabledBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.white.withOpacity(0.3)),),focusedBorder:const UnderlineInputBorder(borderSide:BorderSide(color:Color(0xFF00F5D4)),),errorBorder:const UnderlineInputBorder(borderSide:BorderSide(color:Colors.redAccent),),focusedErrorBorder:const UnderlineInputBorder(borderSide:BorderSide(color:Colors.redAccent,width:2),),); }
  Widget _buildLoginButton() { /* Omitted for brevity, include your existing code */ return SizedBox(width:double.infinity,height:55,child:ElevatedButton(onPressed:_isLoading?null:_login,style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF00F5D4),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)),),child:_isLoading?const CircularProgressIndicator(color:Color(0xFF0D0F20)):Text("LOGIN",style:GoogleFonts.poppins(fontSize:16,fontWeight:FontWeight.bold,color:const Color(0xFF0D0F20),),),),); }
  Widget _buildSignupText() { /* Omitted for brevity, include your existing code */ return GestureDetector(onTap:(){if(_isLoading)return;Navigator.push(context,MaterialPageRoute(builder:(_)=>const SignupScreen()));},child:RichText(text:TextSpan(style:GoogleFonts.poppins(color:Colors.white70),children:const [TextSpan(text:"Don't have an account? "),TextSpan(text:"Sign Up",style:TextStyle(color:Color(0xFF00F5D4),fontWeight:FontWeight.bold,),),]))); }
}
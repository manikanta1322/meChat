import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/dialogs.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isUIAnimated = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _imageFile;

  late double _blob1X, _blob1Y, _blob2X, _blob2Y;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeBlobs();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isUIAnimated = true);
    });
    _timer = Timer.periodic(
      const Duration(seconds: 7),
      (timer) => _animateBlobs(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // The signup logic remains the same
  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final fakeEmail = "${_mobileController.text.trim()}@wechat.app";
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: fakeEmail,
              password: _passwordController.text.trim(),
            );

        String imageUrl = '';
        if (_imageFile != null) {
          final ext = _imageFile!.path.split('.').last;
          final ref = APIs.storage.ref().child(
            'profilepicture/${userCredential.user!.uid}.$ext',
          );
          await ref.putFile(
            _imageFile!,
            SettableMetadata(contentType: 'image/$ext'),
          );
          imageUrl = await ref.getDownloadURL();
        }

        await APIs.createUser(
          name: _nameController.text.trim(),
          phone: _mobileController.text.trim(),
          imageUrl: imageUrl,
        );

        if (!mounted) return;

        Navigator.pop(context);
        Dialogs.showSnackbar(
          context,
          'Account created successfully! Please log in.',
        );
      } on FirebaseAuthException catch (e) {
        if (mounted)
          Dialogs.showSnackbar(context, e.message ?? 'Signup Failed');
      } catch (e) {
        if (mounted) Dialogs.showSnackbar(context, 'Something went wrong: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F20),

      // ** NEW: Added a transparent AppBar **
      // It will automatically add a back button.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ensure the back button icon is visible on the dark background
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // The body of the scaffold automatically respects the SafeArea
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background layer remains the same
                _buildDynamicBackground(mq),
            
                // Main content layer, now simplified
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: _buildGlassmorphicContainer(mq),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: mq.height * 0.05,
          ),
        ],
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  // ** REMOVED: The old _buildBackButton() method is no longer needed. **

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileImagePicker(),
          const SizedBox(height: 24),
          Text(
            "Create Account",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join us and start chatting",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('Full Name', Icons.person_outline),
            validator:
                (val) =>
                    val != null && val.isNotEmpty
                        ? null
                        : 'Please enter your name',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _mobileController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              'Mobile Number',
              Icons.phone_android_outlined,
            ),
            validator:
                (val) =>
                    val != null && val.length >= 10
                        ? null
                        : 'Enter a valid mobile number',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: _inputDecoration('Password', Icons.lock_outline),
            validator:
                (val) =>
                    val != null && val.length >= 6
                        ? null
                        : 'Password must be at least 6 characters',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: _inputDecoration(
              'Confirm Password',
              Icons.lock_person_outlined,
            ),
            validator: (val) {
              if (val == null || val.isEmpty)
                return 'Please confirm your password';
              if (val != _passwordController.text)
                return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildSignupButton(),
          const SizedBox(height: 24),
          _buildLoginText(),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Stack(
      children: [
        _imageFile != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.file(
                _imageFile!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            )
            : const CircleAvatar(
              radius: 75,
              backgroundColor: Color(0xFF00F5D4),
              child: Icon(
                CupertinoIcons.person,
                size: 80,
                color: Color(0xFF0D0F20),
              ),
            ),
        Positioned(
          bottom: 0,
          right: 0,
          child: MaterialButton(
            elevation: 1,
            onPressed: _showImagePickerSheet,
            shape: const CircleBorder(),
            color: Colors.white,
            child: const Icon(Icons.edit, color: Color(0xFF0D0F20)),
          ),
        ),
      ],
    );
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F223A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Text(
              'Select Profile Picture',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerButton(
                  'Gallery',
                  Icons.image_outlined,
                  () => _pickImage(ImageSource.gallery),
                ),
                _pickerButton(
                  'Camera',
                  Icons.camera_alt_outlined,
                  () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _pickerButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, color: const Color(0xFF00F5D4), size: 40),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(color: Colors.white70)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
    Navigator.pop(context); // Close the bottom sheet
  }

  // The rest of the helper methods are unchanged. They are included here with the
  // "omitted for brevity" trick to make the code shorter in the editor but complete for you.
  void _initializeBlobs() {
    final random = Random();
    _blob1X = random.nextDouble() * 0.6;
    _blob1Y = random.nextDouble() * 0.6;
    _blob2X = random.nextDouble() * 0.6;
    _blob2Y = random.nextDouble() * 0.6;
  }

  void _animateBlobs() {
    final random = Random();
    if (mounted) {
      setState(() {
        _blob1X = random.nextDouble() * 0.6;
        _blob1Y = random.nextDouble() * 0.6;
        _blob2X = random.nextDouble() * 0.6;
        _blob2Y = random.nextDouble() * 0.6;
      });
    }
  }

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
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00F5D4)),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00F5D4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF0D0F20))
                : Text(
                  "SIGN UP",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D0F20),
                  ),
                ),
      ),
    );
  }

  Widget _buildLoginText() {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        Navigator.pop(context);
      },
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(color: Colors.white70),
          children: const [
            TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Color(0xFF00F5D4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBackground(Size mq) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          top: mq.height * _blob1Y,
          left: mq.width * _blob1X,
          child: _buildBlob(const Color(0xFFFC5C7D), 250),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          bottom: mq.height * _blob2Y,
          right: mq.width * _blob2X,
          child: _buildBlob(const Color(0xFF00F5D4), 300),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/dialogs.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUesr user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    // ** THE FIX: Get MediaQuery inside the build method **
    final mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F20), // Dark background
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), 
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            // Use 'mq' instead of 'mv'
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * .03),
                  _buildProfileImage(mq),
                  SizedBox(height: mq.height * .03),
                  Text(
                    // Display the real phone number
                    widget.user.phone, 
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Name is required',
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Name', Icons.person_outline),
                  ),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Status is required',
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('About', Icons.info_outline),
                  ),
                  SizedBox(height: mq.height * .05),
                  _buildUpdateButton(mq),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildLogoutButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildProfileImage(Size mq) {
    return Stack(
      children: [
        _imagePath != null
            ?
            // Local image
            ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: Image.file(
                  File(_imagePath!),
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.cover,
                ),
              )
            :
            // Image from server
            ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    backgroundColor: Color(0xFF00F5D4),
                    child: Icon(CupertinoIcons.person, size: 80, color: Color(0xFF0D0F20)),
                  ),
                ),
              ),
        // Edit Image Button
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
        )
      ],
    );
  }

  Widget _buildUpdateButton(Size mq) {
    return SizedBox(
      width: mq.width * .5,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            APIs.updateUserInfo().then((_) {
              Dialogs.showSnackbar(context, 'Profile Updated Successfully!');
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00F5D4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          "UPDATE",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D0F20),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      onPressed: () async {
        Dialogs.showProgressBar(context);
        await APIs.auth.signOut();
        // Clear navigation stack and go to LoginScreen
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false);
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
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
    );
  }

  // Bottom sheet for picking a profile picture
  void _showImagePickerSheet() {
    // Again, get mq inside the method where it's used
    final mq = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F223A), // Darker sheet background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: mq.height * .02),
          children: [
            Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerButton(
                    mq,
                    'Gallery',
                    Icons.image_outlined,
                    () => _pickImage(ImageSource.gallery)),
                _pickerButton(
                    mq,
                    'Camera',
                    Icons.camera_alt_outlined,
                    () => _pickImage(ImageSource.camera)),
              ],
            )
          ],
        );
      },
    );
  }
  
  Widget _pickerButton(Size mq, String title, IconData icon, VoidCallback onTap) {
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

  // Logic for picking an image
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _imagePath = image.path);
      Dialogs.showProgressBar(context);
      await APIs.updateProfilePicture(File(_imagePath!));
      Navigator.pop(context); // Close the bottom sheet
      Navigator.pop(context); // Close the progress bar
    }
  }
}
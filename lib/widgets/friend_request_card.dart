// lib/widgets/friend_request_card.dart

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/models/chatUser.dart';

class FriendRequestCard extends StatelessWidget {
  final ChatUesr user;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestCard({
    super.key,
    required this.user,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    width: 50, height: 50,
                    imageUrl: user.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    user.name,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                  onPressed: onReject,
                ),
                IconButton(
                  icon: const Icon(Icons.check_rounded, color: Color(0xFF00F5D4)),
                  onPressed: onAccept,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
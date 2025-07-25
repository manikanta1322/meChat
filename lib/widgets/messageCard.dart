// lib/widgets/messageCard.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/myDateUtil.dart';
import 'package:we_chat/models/messages.dart';

class MessageCard extends StatelessWidget {
  final Messages messages;
  const MessageCard({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == messages.fromId;
    return isMe ? _greenMessage(context) : _blueMessage(context);
  }

  // Sender's message (the other user)
  Widget _blueMessage(BuildContext context) {
    // Update last read message if sender and receiver are different
    if (messages.read.isEmpty) {
      APIs.updateMessageReadStatus(messages);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(messages.type == Type.image ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(),
                const SizedBox(height: 4),
                Text(
                  MyDateUtil.getformattedTime(context: context, time: messages.sent),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Our message (the current user)
  Widget _greenMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(messages.type == Type.image ? 8 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5D4).withOpacity(0.2), // Accent color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMessageContent(),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      MyDateUtil.getformattedTime(context: context, time: messages.sent),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(width: 5),
                    if (messages.read.isNotEmpty)
                      const Icon(Icons.done_all_rounded, color: Colors.cyanAccent, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent() {
    return messages.type == Type.text
        ? Text(
            messages.msg,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: messages.msg,
              placeholder: (context, url) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.image, size: 70),
            ),
          );
  }
}
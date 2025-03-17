// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/myDateUtil.dart';
import 'package:we_chat/models/messages.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MessageCard extends StatefulWidget {
  final Messages messages;
  const MessageCard({super.key, required this.messages});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.messages.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // Function to show dialog when image is tapped
  void _showImageOptions(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Options'),
        content: const Text('Do you want to download this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  // Sender's message
  Widget _blueMessage() {
    if (widget.messages.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.messages);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding:
                EdgeInsets.all(widget.messages.type == Type.image ? 12 : 16),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 203, 225, 243),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: widget.messages.type == Type.text
                ? Text(
                    widget.messages.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : GestureDetector(
                    onTap: () => _showImageOptions(widget.messages.msg),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.messages.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            MyDateUtil.getformattedTime(
                context: context, time: widget.messages.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // Receiver's message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            if (widget.messages.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 2),
            Text(
              MyDateUtil.getformattedTime(
                  context: context, time: widget.messages.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding:
                EdgeInsets.all(widget.messages.type == Type.image ? 12 : 16),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 208, 243, 203),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: widget.messages.type == Type.text
                ? Text(
                    widget.messages.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : GestureDetector(
                    onTap: () => _showImageOptions(widget.messages.msg),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.messages.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

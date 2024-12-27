// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helpers/myDateUtil.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/messages.dart';

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

  // sender or another user message
  Widget _blueMessage() {
    // update last read message if sender and receiver are different
    if (widget.messages.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.messages);
      print('message read upload');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? mv.width * .03
                : mv.width * .04),
            margin: EdgeInsets.symmetric(
                vertical: mv.height * .01, horizontal: mv.width * .04),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 203, 225, 243),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: widget.messages.type == Type.text
                ? Text(
                    widget.messages.msg,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mv.height * .03),
                    child: CachedNetworkImage(
                      // width: mv.width * .05,
                      // height: mv.height * .05,
                      imageUrl: widget.messages.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mv.width * .04),
          child: Text(
            MyDateUtil.getformattedTime(
                context: context, time: widget.messages.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mv.width * .04,
            ),
            if (widget.messages.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getformattedTime(
                  context: context, time: widget.messages.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? mv.width * .03
                : mv.width * .04),
            margin: EdgeInsets.symmetric(
                vertical: mv.height * .01, horizontal: mv.width * .04),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 208, 243, 203),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: widget.messages.type == Type.text
                ? Text(
                    widget.messages.msg,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mv.height * .03),
                    child: CachedNetworkImage(
                      // width: mv.width * .05,
                      // height: mv.height * .05,
                      imageUrl: widget.messages.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    )),
          ),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/screens/auth/ChatScreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUesr user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mv.width * .04, vertical: 4),
      color: Colors.blue.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
          },
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mv.height * .3),
              child: CachedNetworkImage(
                  width: mv.height * .055,
                  height: mv.height * .055,
                  imageUrl: widget.user.image.toString(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundImage: AssetImage('images/man.png'))),
            ),
            title: Text(widget.user.name.toString()),
            subtitle: Text(
              widget.user.about.toString(),
              maxLines: 1,
            ),
            trailing: Text(
              'Online',
              style: TextStyle(
                  color: Colors.greenAccent.shade700,
                  fontWeight: FontWeight.w700),
            ),

            // trailing: const Text(
            //   '12:00 PM',
            //   style: TextStyle(
            //     color: Colors.black54,
            //   ),
            // ),
          )),
    );
  }
}

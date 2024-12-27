import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/models/messages.dart';
import 'package:we_chat/screens/auth/ChatScreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUesr user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Messages? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mv.width * .04, vertical: 4),
      color: Colors.blue.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            final data = snapshot.data?.docs;
            // if(data != null && data.first.exists){
            final list =
                data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }

            // }
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mv.height * .3),
                child: CachedNetworkImage(
                    width: mv.height * .055,
                    height: mv.height * .055,
                    imageUrl: widget.user.image.toString(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/man.png'))),
              ),
              title: Text(widget.user.name.toString()),
              subtitle: Text(
                _message != null
                    ? _message!.msg.toString()
                    : widget.user.about.toString(),
                maxLines: 1,
              ),
              trailing: _message == null
                  ? null
                  :
                  
                  _message!.fromId == APIs.user.uid
                      && _message!.read.isEmpty
                          ? 
                   Text(
                      'Online',
                      style: TextStyle(
                          color: Colors.greenAccent.shade700,
                          fontWeight: FontWeight.w700),
                    ):Text(
                _message!.sent.toString(),
                style: const TextStyle(
                  color: Colors.black54,
                ),
              )

             
            );
          },
        ),
      ),
    );
  }
}

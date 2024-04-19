import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mv.width* .04,vertical: 4),
      color: Colors.blue.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {},
          child: const ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('images/man.png'),
            ),
            title: Text('Manikanta'),
            subtitle: Text(
              'Last user message',
              maxLines: 1,
            ),
            trailing: Text(
              '12:00 PM',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          )),
    );
  }
}

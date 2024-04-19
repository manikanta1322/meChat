import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/widgets/chatUserCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text('Me Chat'),
        actions: [
          //search user button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

          //more features button
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      //floating button to add new user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) {
              //     return const LoginScreen();
              //   }),
              // );
            },
            child: const Icon(Icons.add_comment_rounded)),
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          final list = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            for (var i in data!) {
              print('Data : $data');
              list.add(i.data()['name']);
            }
          }
          return ListView.builder(
              itemCount: 15,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: mv.height * .01),
              itemBuilder: (context, index) {
                // return const ChatUserCard();
                return Text('Name: ${list[index]}');
              });
        },
      ),
    );
  }
}

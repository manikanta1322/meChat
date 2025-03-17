// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/screens/auth/addNewFriendsScreen.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/auth/profileScreen.dart';
import 'package:we_chat/widgets/chatUserCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUesr> _list = [];
  final List<ChatUesr> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearching
                  ? TextField(
                      key: const ValueKey(1),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search by Name or Email'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name!
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email!
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                        }
                        setState(() {}); // Update UI
                      },
                    )
                  : const Text('Me Chat'),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() => _isSearching = !_isSearching);
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me)));
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          //floating button to add new user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 80 : 10),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddNewFriendsScreen()),
                );
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: APIs
                .getFriendsStream(), // ✅ Now correctly fetching updated friends list
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No Friends Found",
                          style: TextStyle(fontSize: 20)),
                    );
                  }
                  final data = snapshot.data!.docs;
                  _list = data
                      .map((e) =>
                          ChatUesr.fromJson(e.data() as Map<String, dynamic>))
                      .toList();
                  return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: mv.height * .01),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                        user: _isSearching ? _searchList[index] : _list[index],
                      );
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:audioplayers/audioplayers.dart'; // Add this import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/models/messages.dart';
import 'package:we_chat/widgets/messageCard.dart';

class ChatScreen extends StatefulWidget {
  final ChatUesr user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Messages> _list = [];
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> playNotificationSound() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    print("pushpa readyyy");
    // Use AssetSource to play the sound file
    await audioPlayer
        .play(AssetSource('sounds/peeps.mp3')); // Path to sound file
    print("pushpa readyyyyyy");
  }

  Future<void> showLocalNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('chat_channel_id', 'Chat Notifications',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Message',
      'You have received a new message.',
      platformDetails,
    );
  }

  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
           onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            backgroundColor: const Color.fromARGB(255, 220, 235, 247),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Messages.fromJson(e.data()))
                                  .toList() ??
                              [];
                
                          if (_list.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);
                            });
                
                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == _list.length - 1) {
                                  // When a new message arrives
                                  playNotificationSound();
                                  showLocalNotification();
                                }
                                return MessageCard(messages: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "No Chats Found",
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mv.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          columns: 8,
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black54,
              )),
          ClipRRect(
            borderRadius: BorderRadius.circular(mv.height * .3),
            child: CachedNetworkImage(
                width: mv.height * .05,
                height: mv.height * .05,
                imageUrl: widget.user.image.toString(),
                errorWidget: (context, url, error) => const CircleAvatar(
                    backgroundImage: AssetImage('asstes/images/man.png'))),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              const Text(
                'Last seen not available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mv.height * .01, horizontal: mv.height * .03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(
                          () => _showEmoji = !_showEmoji,
                        );
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      onTap: () {
                        if (_showEmoji)
                          setState(
                            () => _showEmoji = !_showEmoji,
                          );
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type Something....',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                        // click for image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          if (kDebugMode) {
                            print('Image Path: ${image.path}');
                          }
                        
                         await  APIs.sendChatImage(widget.user, File(image.path));
                         
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  SizedBox(
                    width: mv.width * .02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';

                playNotificationSound(); // Play sound when sending
                showLocalNotification(); // Show notification when sending

                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}

// screens/auth/ChatScreen.dart

import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/models/messages.dart';
import 'package:we_chat/widgets/messageCard.dart';
import 'package:we_chat/helpers/dialogs.dart'; // Ensure this is imported for Dialogs

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

  bool _showEmoji = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = false);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0D0F20),
            appBar: _buildAppBar(),
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
                          _list =
                              data
                                  ?.map((e) => Messages.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            // ** IMPROVED SCROLLING LOGIC **
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                // Only auto-scroll if the user is near the bottom
                                final isAtBottom =
                                    _scrollController.position.maxScrollExtent -
                                        _scrollController.position.pixels <
                                    200;
                                if (isAtBottom) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              }
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: _list.length,
                              padding: const EdgeInsets.only(top: 8),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder:
                                  (context, index) =>
                                      MessageCard(messages: _list[index]),
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Say Hi! 👋",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                _buildChatInput(),
                if (_showEmoji) _buildEmojiPicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // All other build methods remain the same as your corrected version
  // ... _buildAppBar, _appBarContent, _buildChatInput, _buildEmojiPicker

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      APIs.sendMessage(widget.user, _textController.text, Type.text);
      _textController.text = '';

      // ** REMOVED: Do not scroll here. Let the StreamBuilder handle it. **
      // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  // The rest of your code (_buildAppBar, _pickImage, etc.) is correct
  // and does not need to be changed.
  // I am including the omitted code for completeness.
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0xFF0D0F20).withOpacity(0.5),
            child: _appBarContent(),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _appBarContent() {
    final mq = MediaQuery.of(context).size;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(mq.height * .03),
          child: CachedNetworkImage(
            width: mq.height * .05,
            height: mq.height * .05,
            fit: BoxFit.cover,
            imageUrl: widget.user.image,
            errorWidget:
                (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Online',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () => setState(() => _showEmoji = false),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          MaterialButton(
            onPressed: _sendMessage,
            minWidth: 0,
            padding: const EdgeInsets.all(12),
            shape: const CircleBorder(),
            color: const Color(0xFF00F5D4),
            child: const Icon(Icons.send, color: Color(0xFF0D0F20), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final mq = MediaQuery.of(context).size;
    return SizedBox(
      height: mq.height * .35,
      child: EmojiPicker(
        textEditingController: _textController,
        config: Config(
          // THE FIX: The main 'backgroundColor' parameter is removed from the top-level Config.
          // It's now handled entirely within the view-specific configs below.

          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            // This sets the background of the emoji grid area.
            backgroundColor: const Color(0xFF0D0F20), 
            
            // This sets the background of the columns (for skin tones, etc.) if they appear.
            // columnBorders: false, 
            emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
          ),
          categoryViewConfig: const CategoryViewConfig(
            // This sets the background of the bottom category bar.
            backgroundColor: Color(0xFF0D0F20),
            
            iconColorSelected: Color(0xFF00F5D4),
            indicatorColor: Color(0xFF00F5D4),
            iconColor: Colors.white54,
            backspaceColor: Color(0xFF00F5D4),
          ),
          // For the search bar, if you enable it
          searchViewConfig: SearchViewConfig(
            backgroundColor: const Color(0xFF0D0F20),
            buttonIconColor: const Color(0xFF00F5D4),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      Dialogs.showProgressBar(context);
      await APIs.sendChatImage(widget.user, File(image.path));
      Navigator.pop(context);
    }
  }
}

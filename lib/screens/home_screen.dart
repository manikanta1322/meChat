// lib/screens/home_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/screens/auth/profileScreen.dart';
import 'package:we_chat/screens/find_friends_screen.dart';
import 'package:we_chat/screens/friend_requests_screen.dart';
import 'package:we_chat/widgets/chatUserCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  // All state variables remain the same
  List<ChatUesr> _friendsList = [];
  final List<ChatUesr> _searchList = [];
  bool _isSearching = false;
  late double _blob1X, _blob1Y, _blob2X, _blob2Y;
  late Timer _timer;
   late TabController _tabController;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    _tabController = TabController(length: 3, vsync: this);
    _initializeBlobs();
    _timer = Timer.periodic(
      const Duration(seconds: 7),
      (timer) => _animateBlobs(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); 
    _timer.cancel();
    super.dispose();
  }

  // All helper methods like _handleSearch, _initializeBlobs, etc., remain the same
  void _handleSearch(String query) {
    /* ... Unchanged ... */
    _searchList.clear();
    if (query.isNotEmpty) {
      for (var user in _friendsList) {
        if (user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.phone.toLowerCase().contains(query.toLowerCase())) {
          _searchList.add(user);
        }
      }
    }
    setState(() {});
  }

  void _initializeBlobs() {
    /* ... Unchanged ... */
    final random = Random();
    _blob1X = random.nextDouble() * 0.6;
    _blob1Y = random.nextDouble() * 0.6;
    _blob2X = random.nextDouble() * 0.6;
    _blob2Y = random.nextDouble() * 0.6;
  }

  void _animateBlobs() {
    /* ... Unchanged ... */
    final random = Random();
    if (mounted)
      setState(() {
        _blob1X = random.nextDouble() * 0.6;
        _blob1Y = random.nextDouble() * 0.6;
        _blob2X = random.nextDouble() * 0.6;
        _blob2Y = random.nextDouble() * 0.6;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F20),
        appBar: _buildAppBar(),
        body: Stack(
          children: [_buildDynamicBackground(context), _buildFriendsList()],
        ),
        // ** REPLACED: Use the SpeedDial widget instead of a standard FAB **
        floatingActionButton: _buildSpeedDial(),
      ),
    );
  }

  // ** NEW: Method to build the SpeedDial FAB **
  Widget _buildSpeedDial() {
    return SpeedDial(
      // The icon that animates (e.g., from menu to close)
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      backgroundColor: const Color(0xFF00F5D4),
      foregroundColor: const Color(0xFF0D0F20),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // "Find Friends" button
        SpeedDialChild(
          child: const Icon(CupertinoIcons.search, color: Color(0xFF0D0F20)),
          backgroundColor: Colors.white,
          label: 'Find New Friends',
          labelStyle: GoogleFonts.poppins(fontSize: 16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FindFriendsScreen()),
            );
          },
        ),
        // "Friend Requests" button
        SpeedDialChild(
          // Use a custom child to accommodate the notification badge
          child: _buildRequestBadge(),
          backgroundColor: Colors.white,
          label: 'Friend Requests',
          labelStyle: GoogleFonts.poppins(fontSize: 16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
            );
          },
        ),
      ],
    );
  }

  // ** REMOVED: The old _showAddFriendsMenu() is no longer needed **

  // ** NEW: This logic is now used inside the SpeedDialChild **
  Widget _buildRequestBadge() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: APIs.getFriendRequests(),
      builder: (context, snapshot) {
        final requestCount =
            (snapshot.data?.data()?['received_requests'] as List?)?.length ?? 0;

        // Base icon
        Widget icon = const Icon(
          CupertinoIcons.person_2_fill,
          color: Color(0xFF0D0F20),
        );

        // If there are requests, wrap the icon in a Stack with a badge
        if (requestCount > 0) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              icon,
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    requestCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // If no requests, just return the plain icon
        return icon;
      },
    );
  }

  // The rest of the screen's build methods are unchanged.
  // ... _buildAppBar, _buildSearchBar, _buildFriendsList, etc.
  AppBar _buildAppBar() {
    /* ... Unchanged ... */
    return AppBar(
      backgroundColor: const Color(0xFF0D0F20).withOpacity(0.5),
      elevation: 0,
      title:
          _isSearching
              ? _buildSearchBar()
              : Text(
                'Me Chat',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      actions:
          _isSearching
              ? null
              : [
                IconButton(
                  icon: const Icon(CupertinoIcons.search, color: Colors.white),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.person_crop_circle,
                    color: Colors.white,
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me),
                        ),
                      ),
                ),
              ],
    );
  }

  Widget _buildSearchBar() {
    /* ... Unchanged ... */
    return TextField(
      autofocus: true,
      style: GoogleFonts.poppins(color: Colors.white),
      cursorColor: const Color(0xFF00F5D4),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(
            CupertinoIcons.clear_circled_solid,
            color: Colors.white54,
          ),
          onPressed: () => setState(() => _isSearching = false),
        ),
      ),
      onChanged: _handleSearch,
    );
  }

  Widget _buildFriendsList() {
    /* ... Unchanged ... */
    return StreamBuilder(
      stream: APIs.getFriendsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        final data = snapshot.data?.docs;
        _friendsList =
            data
                ?.map(
                  (e) => ChatUesr.fromJson(e.data() as Map<String, dynamic>),
                )
                .toList() ??
            [];
        final listToShow = _isSearching ? _searchList : _friendsList;
        if (listToShow.isNotEmpty) {
          return ListView.builder(
            itemCount: listToShow.length,
            padding: const EdgeInsets.only(top: 8),
            physics: const BouncingScrollPhysics(),
            itemBuilder:
                (context, index) => ChatUserCard(user: listToShow[index]),
          );
        } else {
          return Center(
            child: Text(
              'No Chats Found. Add some friends!',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          );
        }
      },
    );
  }

  Widget _buildDynamicBackground(BuildContext context) {
    /* ... Unchanged ... */
    final mq = MediaQuery.of(context).size;
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          top: mq.height * _blob1Y,
          left: mq.width * _blob1X,
          child: _buildBlob(const Color(0xFFFC5C7D), 250),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          bottom: mq.height * _blob2Y,
          right: mq.width * _blob2X,
          child: _buildBlob(const Color(0xFF00F5D4), 300),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    /* ... Unchanged ... */
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

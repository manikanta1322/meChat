// lib/screens/find_friends_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/widgets/find_friend_card.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

// ** ADDED: with SingleTickerProviderStateMixin for the TabController **
class _FindFriendsScreenState extends State<FindFriendsScreen> with SingleTickerProviderStateMixin {
  
  // State variables for the "Discover" tab
  List<ChatUesr> _discoverUsersList = [];
  Map<String, bool> _requestStatus = {};

  // ** NEW: TabController **
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
    // Fetch initial request status for the "Discover" tab
    _updateRequestStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateRequestStatus() async {
    final pending = await APIs.getPendingRequests();
    if (mounted) {
      setState(() {
        _requestStatus = {for (var id in pending) id: true};
      });
    }
  }

  void _sendRequest(String userId) {
    APIs.sendFriendRequest(userId);
    // Update the UI immediately for a responsive feel
    setState(() {
      _requestStatus[userId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F20),
      appBar: AppBar(
        title: Text('Find Friends', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        // ** NEW: TabBar at the bottom of the AppBar **
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00F5D4),
          labelColor: const Color(0xFF00F5D4),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "DISCOVER"),
            Tab(text: "SENT"),
          ],
        ),
      ),
      // ** NEW: TabBarView to display content for each tab **
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildSentRequestsTab(),
        ],
      ),
    );
  }

  /// WIDGET BUILDER FOR THE "DISCOVER" TAB
  Widget _buildDiscoverTab() {
    // This logic is similar to your original screen
    return FutureBuilder<List<String>>(
      // First, get IDs of friends and users with pending requests to exclude them
      future: Future.wait([APIs.getFriendsList(), APIs.getPendingRequests()])
          .then((lists) => [...lists[0], ...lists[1]]),
      builder: (context, excludedSnapshot) {
        final excludedIds = Set<String>.from(excludedSnapshot.data ?? []);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: APIs.getAllUsers(),
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final allUsers = usersSnapshot.data?.docs.map((e) => ChatUesr.fromJson(e.data())).toList() ?? [];
            
            // Filter out self, friends, and users with pending requests
            _discoverUsersList = allUsers.where((user) => user.id != APIs.user.uid && !excludedIds.contains(user.id)).toList();

            if (_discoverUsersList.isEmpty) {
              return Center(child: Text('No New Users Found', style: GoogleFonts.poppins(color: Colors.white70)));
            }

            return ListView.builder(
              itemCount: _discoverUsersList.length,
              padding: const EdgeInsets.only(top: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final user = _discoverUsersList[index];
                final isAdded = _requestStatus[user.id] ?? false;
                return FindFriendCard(
                  user: user,
                  isAdded: isAdded,
                  onAdd: () => _sendRequest(user.id),
                );
              },
            );
          },
        );
      },
    );
  }
  
  /// WIDGET BUILDER FOR THE "SENT REQUESTS" TAB
  Widget _buildSentRequestsTab() {
    return FutureBuilder<List<String>>(
      // First, get the list of user IDs we've sent requests to
      future: APIs.getPendingRequests(),
      builder: (context, sentIdsSnapshot) {
        if (sentIdsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final sentRequestIds = sentIdsSnapshot.data ?? [];

        if (sentRequestIds.isEmpty) {
          return Center(child: Text('No Sent Requests', style: GoogleFonts.poppins(color: Colors.white70)));
        }

        // Now, fetch the full user details for each ID
        return FutureBuilder<List<ChatUesr?>>(
          future: Future.wait(sentRequestIds.map((id) => APIs.getUserById(id))),
          builder: (context, usersSnapshot) {
            if (!usersSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            
            final sentUsersList = usersSnapshot.data!.whereType<ChatUesr>().toList();
            
            return ListView.builder(
              itemCount: sentUsersList.length,
              padding: const EdgeInsets.only(top: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final user = sentUsersList[index];
                // In this list, the button is always disabled ("Sent")
                return FindFriendCard(
                  user: user,
                  isAdded: true,
                  onAdd: () {}, // Empty function as it's disabled
                );
              },
            );
          },
        );
      },
    );
  }
}
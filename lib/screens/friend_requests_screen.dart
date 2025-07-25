// lib/screens/friend_requests_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/widgets/friend_request_card.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<ChatUesr> _requestsList = [];
  final api = APIs(); // Instance for non-static methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F20),
      appBar: AppBar(
        title: Text('Friend Requests', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: APIs.getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          
          final requestIds = List<String>.from(snapshot.data?.data()?['received_requests'] ?? []);
          
          if (requestIds.isEmpty) {
            return Center(child: Text('No Friend Requests', style: GoogleFonts.poppins(color: Colors.white70)));
          }

          return FutureBuilder<List<ChatUesr?>>(
            future: Future.wait(requestIds.map((id) => APIs.getUserById(id))),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              
              _requestsList = userSnapshot.data!.whereType<ChatUesr>().toList();
              
              return ListView.builder(
                itemCount: _requestsList.length,
                padding: const EdgeInsets.only(top: 8),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final user = _requestsList[index];
                  return FriendRequestCard(
                    user: user,
                    onAccept: () => api.acceptFriendRequest(user.id),
                    onReject: () => api.rejectFriendRequest(user.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
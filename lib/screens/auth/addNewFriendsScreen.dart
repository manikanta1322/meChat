import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/screens/auth/friendRequestScreen.dart';

class AddNewFriendsScreen extends StatefulWidget {
  const AddNewFriendsScreen({super.key});

  @override
  State<AddNewFriendsScreen> createState() => _AddNewFriendsScreenState();
}

class _AddNewFriendsScreenState extends State<AddNewFriendsScreen> {
  List<ChatUesr> _usersList = [];
  Map<String, bool> _addedUsers = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    APIs.getAllUsers().listen((snapshot) async {
      final data = snapshot.docs;
      List<ChatUesr> users =
          data.map((e) => ChatUesr.fromJson(e.data())).toList();

      // Get list of pending friend requests
      List<String> pendingRequests = await APIs.getPendingRequests();

      // Get list of friends
      List<String> friends = await APIs.getFriendsList();

      setState(() {
        _usersList = users
            .where((user) => !friends.contains(user.id))
            .toList(); // Exclude friends
        _addedUsers = {
          for (var userId in pendingRequests) userId: true
        }; // Track sent requests
      });
    });
  }

  void _toggleAdd(String userId) async {
    if (!_addedUsers.containsKey(userId)) {
      await APIs.sendFriendRequest(userId); // Send friend request

      setState(() {
        _addedUsers[userId] = true; // Persist UI change
      });

      // Store in Firestore under "sent_requests"
      await APIs.firestore
          .collection('friend_requests')
          .doc(APIs.auth.currentUser!.uid)
          .set({
        'sent_requests': FieldValue.arrayUnion([userId])
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Friends"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add,
                color: Colors.black), // Friend request icon
            onPressed: () {
              // Navigate to FriendRequestsScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FriendRequestsScreen()),
              );
            },
          ),
        ],
      ),
      body: _usersList.isEmpty
          ? const Center(
              child: Text(
                "No users found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                final user = _usersList[index];
                final isAdded = _addedUsers[user.id] ?? false;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          user.image != null ? NetworkImage(user.image!) : null,
                      child: user.image == null
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.black)
                          : null,
                    ),
                    title: Text(
                      user.name ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    trailing: ElevatedButton(
                      onPressed: isAdded ? null : () => _toggleAdd(user.id!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded ? Colors.grey : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      child: Text(
                        isAdded ? "Sent" : "Add",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

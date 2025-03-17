import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chatUser.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<ChatUesr> _requestsList = [];
  final api = APIs();

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  void _fetchFriendRequests() {
    APIs.getFriendRequests().listen((snapshot) {
      if (snapshot.exists) {
        final List<String> requestIds =
            List<String>.from(snapshot.data()?['requests'] ?? []);

        // Fetch user details from user IDs
        Future.wait(requestIds.map((id) => APIs.getUserById(id))).then((users) {
          setState(() {
            _requestsList = users.whereType<ChatUesr>().toList();
          });
        });
      }
    });
  }

  void _acceptRequest(String userId) async {
    await api.acceptFriendRequest(userId);
    setState(() {
      _requestsList.removeWhere((user) => user.id == userId);
    });
  }

  void _rejectRequest(String userId) async {
    await api.rejectFriendRequest(userId);
    setState(() {
      _requestsList.removeWhere((user) => user.id == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),
      body: _requestsList.isEmpty
          ? const Center(child: Text("No friend requests"))
          : ListView.builder(
              itemCount: _requestsList.length,
              itemBuilder: (context, index) {
                final user = _requestsList[index];
                return Dismissible(
                  key: Key(user.id!),
                  direction: DismissDirection.horizontal,
                  background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.check, color: Colors.white)),
                  secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.close, color: Colors.white)),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _acceptRequest(user.id!);
                    } else {
                      _rejectRequest(user.id!);
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          user.image != null ? NetworkImage(user.image!) : null,
                      child: user.image == null
                          ? Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(user.name ?? "Unknown"),
                    subtitle: Text(user.email ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Accept Button
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _acceptRequest(user.id!),
                        ),
                        // ❌ Reject Button
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _rejectRequest(user.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

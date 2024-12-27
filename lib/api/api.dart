import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:we_chat/models/chatUser.dart';
import 'package:we_chat/models/messages.dart';

class APIs {
  //fpr authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUesr me;

  // to return current user
  static get user => auth.currentUser!;

  // for checking user exit or not ??
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUesr.fromJson(user.data()!);
        if (kDebugMode) {
          print('My Data : ${user.data()}');
        }
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUesr(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I am using Me Chat!",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users data from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for updating the user information
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // for updating profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    if (kDebugMode) {
      print('Extension: $ext');
    }

    // storage file ref with path
    final ref = storage.ref().child('profilepicture/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      if (kDebugMode) {
        print('Data Transferred : ${p0.bytesTransferred / 1000}');
      }
    });

    // updating image to the firebase database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  /// ***************** Chat screen APIs ****************
  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

// useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUesr user) {
    return firestore
        .collection('chats/${getConversationId(user.id.toString())}/messages/')
        .snapshots();
  }

  // for sending messages
  static Future<void> sendMessage(ChatUesr chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
// message to send
    final Messages message = Messages(
        toId: chatUser.id.toString(),
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);
    final ref = firestore.collection(
        'chats/${getConversationId(chatUser.id.toString())}/messages/');
    await ref.doc().set(message.toJson());
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Messages message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(ChatUesr user) {
    return firestore
        .collection('chats/${getConversationId(user.id.toString())}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUesr chatUser, File file) async {
   final ext = file.path.split('.').last;
  

    // storage file ref with path
    final ref = storage.ref().child('images/${getConversationId(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      if (kDebugMode) {
        print('Data Transferred : ${p0.bytesTransferred / 1000}');
      }
    });

    // updating image to the firebase database
   final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}

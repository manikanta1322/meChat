// in models/chatUser.dart

class ChatUesr {
  ChatUesr({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.phone, // <-- ADD THIS TO CONSTRUCTOR
  });
  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String phone; // <-- The field itself

  // Factory constructor for creating a new ChatUesr instance from a map
  ChatUesr.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? false;
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    phone = json['phone'] ?? ''; // <-- ADD THIS TO fromJson
  }

  // Method to convert a ChatUesr instance to a map
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['phone'] = phone; // <-- ADD THIS TO toJson
    return data;
  }
}
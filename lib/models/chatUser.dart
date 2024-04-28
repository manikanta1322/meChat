class ChatUesr {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  String? lastActive;
  bool? isOnline;
  String? id;
  String? email;
  String? pushToken;

  ChatUesr(
      {this.image,
      this.about,
      this.name,
      this.createdAt,
      this.lastActive,
      this.isOnline,
      this.id,
      this.email,
      this.pushToken});

  ChatUesr.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? "";
    about = json['about'] ?? "";
    name = json['name'] ?? "";
    createdAt = json['created_at'] ?? "";
    lastActive = json['last_active'] ?? "";
    isOnline = json['is_online'];
    id = json['id'] ?? "";
    email = json['email'] ?? "";
    pushToken = json['push_token'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['about'] = this.about;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['last_active'] = this.lastActive;
    data['is_online'] = this.isOnline;
    data['id'] = this.id;
    data['email'] = this.email;
    data['push_token'] = this.pushToken;
    return data;
  }
}

enum MessageStatus {
  sending, // ⏳ abhi bhej rahe ho
  sent, // ✅ ek tick
  delivered, // ✅✅ double tick
  read, // ✅✅ blue tick (agar chahiye to color change kar dena)
}

class Chat {
  final String id;
  final String? productId;
  final String? productName;
  final String? sellerId;
  final String? buyerId;
  final String? sellerName;
  final String? productImage;
  final String? profilePicture;
  String? lastMessage;
  String? time;
  final int unreadCount;

  Chat({
    required this.id,
    this.productId,
    this.productName,
    this.sellerId,
    this.buyerId,
    this.sellerName,
    this.productImage,
    this.profilePicture,
    this.lastMessage,
    this.time,
    this.unreadCount = 0,
  });

  String get displayName {
    if ((productName ?? '').trim().isNotEmpty) return productName!.trim();
    if ((sellerName ?? '').trim().isNotEmpty) return sellerName!.trim();
    return 'Chat';
  }

  Chat copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sellerId,
    String? buyerId,
    String? sellerName,
    String? productImage,
    String? profilePicture,
    String? lastMessage,
    String? time,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      sellerName: sellerName ?? this.sellerName,
      productImage: productImage ?? this.productImage,
      profilePicture: profilePicture ?? this.profilePicture,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    String? imageUrl;

    // Multiple ways to extract product image - backend se different formats aa sakte hain
    if (json['productId'] is Map &&
        json['productId']['productImages'] is List &&
        (json['productId']['productImages'] as List).isNotEmpty) {
      final firstImage = (json['productId']['productImages'] as List).first;
      if (firstImage is String) {
        imageUrl = firstImage;
      } else if (firstImage is Map && firstImage['url'] != null) {
        imageUrl = firstImage['url']?.toString();
      }
    } else if (json['productId'] is Map &&
        json['productId']['mediaUrl'] is List &&
        (json['productId']['mediaUrl'] as List).isNotEmpty) {
      // mediaUrl se bhi try karte hain
      imageUrl = (json['productId']['mediaUrl'] as List).first?.toString();
    } else if (json['productId'] is Map &&
        json['productId']['images'] is List &&
        (json['productId']['images'] as List).isNotEmpty) {
      // images array se bhi try karte hain
      imageUrl = (json['productId']['images'] as List).first?.toString();
    } else if (json['productImage'] != null) {
      imageUrl = json['productImage']?.toString();
    }

    // URL formatting - full URL banate hain agar relative path hai
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl =
          'https://oldmarket.bhoomi.cloud/${imageUrl.replaceAll('\\', '/')}';
    }

    return Chat(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: json['productId'] is Map
          ? json['productId']['_id']?.toString()
          : json['productId']?.toString(),
      productName: json['productId'] is Map
          ? json['productId']['title']
          : json['productName'],
      sellerId: json['sellerId'] is Map
          ? json['sellerId']['_id']?.toString()
          : json['sellerId']?.toString(),
      sellerName: json['sellerId'] is Map
          ? json['sellerId']['name']
          : json['sellerName'],
      buyerId: json['buyerId'] is Map
          ? json['buyerId']['_id']?.toString()
          : json['buyerId']?.toString(),
      productImage: imageUrl,
      lastMessage: json['lastMessage'] is Map
          ? json['lastMessage']['content']
          : json['lastMessage'],
      time: json['lastMessage'] is Map
          ? json['lastMessage']['createdAt']
          : json['time'],
      profilePicture: json['profilePicture']?.toString(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  MessageStatus status; // ✅ Tick status ke liye
  bool isEdited; // ✅ Edit track karne ke liye

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.status = MessageStatus.sending,
    this.isEdited = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status']),
      isEdited: json['isEdited'] ?? false,
    );
  }

  static MessageStatus _parseStatus(dynamic value) {
    switch (value) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'isEdited': isEdited,
    };
  }

  Message copyWith({String? content, MessageStatus? status, bool? isEdited}) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content ?? this.content,
      createdAt: createdAt,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

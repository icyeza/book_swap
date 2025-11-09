import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool emailVerified;
  final Map<String, bool> notificationSettings;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.emailVerified = false,
    Map<String, bool>? notificationSettings,
  }) : notificationSettings =
           notificationSettings ??
           {'swapRequests': true, 'messages': true, 'updates': true};

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    bool? emailVerified,
    Map<String, bool>? notificationSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'emailVerified': emailVerified,
      'notificationSettings': notificationSettings,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      emailVerified: data['emailVerified'] ?? false,
      notificationSettings: Map<String, bool>.from(
        data['notificationSettings'] ??
            {'swapRequests': true, 'messages': true, 'updates': true},
      ),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      emailVerified: data['emailVerified'] ?? false,
      notificationSettings: Map<String, bool>.from(
        data['notificationSettings'] ??
            {'swapRequests': true, 'messages': true, 'updates': true},
      ),
    );
  }
}

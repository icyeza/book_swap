import 'package:cloud_firestore/cloud_firestore.dart';

class SwapOffer {
  final String id;
  final String requestedBookId;
  final String offeredBookId;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? chatId;

  SwapOffer({
    required this.id,
    required this.requestedBookId,
    required this.offeredBookId,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.chatId,
  });

  SwapOffer copyWith({
    String? id,
    String? requestedBookId,
    String? offeredBookId,
    String? requesterId,
    String? requesterName,
    String? ownerId,
    String? ownerName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? chatId,
  }) {
    return SwapOffer(
      id: id ?? this.id,
      requestedBookId: requestedBookId ?? this.requestedBookId,
      offeredBookId: offeredBookId ?? this.offeredBookId,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chatId: chatId ?? this.chatId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestedBookId': requestedBookId,
      'offeredBookId': offeredBookId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'chatId': chatId,
    };
  }

  factory SwapOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapOffer(
      id: doc.id,
      requestedBookId: data['requestedBookId'] ?? '',
      offeredBookId: data['offeredBookId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      chatId: data['chatId'],
    );
  }

  factory SwapOffer.fromMap(Map<String, dynamic> data, String id) {
    return SwapOffer(
      id: id,
      requestedBookId: data['requestedBookId'] ?? '',
      offeredBookId: data['offeredBookId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      chatId: data['chatId'],
    );
  }
}

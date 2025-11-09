import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String category;
  final String condition;
  final String? description;
  final DateTime datePosted;
  final String? imageUrl;
  final bool isAvailable;
  final String status; // 'available', 'pending', 'swapped'

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.category,
    required this.condition,
    this.description,
    required this.datePosted,
    this.imageUrl,
    this.isAvailable = true,
    this.status = 'available',
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(datePosted);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Create a copy of the book with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? category,
    String? condition,
    String? description,
    DateTime? datePosted,
    String? imageUrl,
    bool? isAvailable,
    String? status,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      datePosted: datePosted ?? this.datePosted,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'category': category,
      'condition': condition,
      'description': description,
      'datePosted': Timestamp.fromDate(datePosted),
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'status': status,
    };
  }

  // Create from Firestore document
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      category: data['category'] ?? '',
      condition: data['condition'] ?? '',
      description: data['description'],
      datePosted: (data['datePosted'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      status: data['status'] ?? 'available',
    );
  }

  // Create from Map
  factory Book.fromMap(Map<String, dynamic> data, String id) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      category: data['category'] ?? '',
      condition: data['condition'] ?? '',
      description: data['description'],
      datePosted: (data['datePosted'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      status: data['status'] ?? 'available',
    );
  }
}

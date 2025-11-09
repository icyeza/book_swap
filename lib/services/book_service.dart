import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  // Create a new book listing
  Future<String> createBook(Book book) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(book.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create book: $e');
    }
  }

  // Get all books
  Stream<List<Book>> getAllBooks() {
    return _firestore
        .collection(_collection)
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }

  // Get books by category
  Stream<List<Book>> getBooksByCategory(String category) {
    if (category == 'All') {
      return getAllBooks();
    }
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }

  // Get books by owner
  Stream<List<Book>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }

  // Get a single book
  Future<Book?> getBook(String bookId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookId).get();
      if (doc.exists) {
        return Book.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  // Get a single book as stream
  Stream<Book?> getBookStream(String bookId) {
    return _firestore
        .collection(_collection)
        .doc(bookId)
        .snapshots()
        .map((doc) => doc.exists ? Book.fromFirestore(doc) : null);
  }

  // Update book
  Future<void> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update(updates);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection(_collection).doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Update book status
  Future<void> updateBookStatus(String bookId, String status) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update({
        'status': status,
        'isAvailable': status == 'available',
      });
    } catch (e) {
      throw Exception('Failed to update book status: $e');
    }
  }

  // Transfer book ownership
  Future<void> transferBookOwnership(
    String bookId,
    String newOwnerId,
    String newOwnerName,
    String newOwnerEmail,
  ) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update({
        'ownerId': newOwnerId,
        'ownerName': newOwnerName,
        'ownerEmail': newOwnerEmail,
        'status': 'swapped',
        'isAvailable': true,
        'datePosted':
            Timestamp.now(), // Reset date to show as recently acquired
      });
    } catch (e) {
      throw Exception('Failed to transfer book ownership: $e');
    }
  }

  // Search books
  Stream<List<Book>> searchBooks(String query) {
    // Note: For better search functionality, consider using Algolia or similar
    // This is a basic implementation
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final books = snapshot.docs
          .map((doc) => Book.fromFirestore(doc))
          .toList();
      return books.where((book) {
        final titleMatch = book.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        final authorMatch = book.author.toLowerCase().contains(
          query.toLowerCase(),
        );
        return titleMatch || authorMatch;
      }).toList();
    });
  }

  // Get available books
  Stream<List<Book>> getAvailableBooks() {
    return _firestore
        .collection(_collection)
        .where('isAvailable', isEqualTo: true)
        .where('status', isEqualTo: 'available')
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }
}

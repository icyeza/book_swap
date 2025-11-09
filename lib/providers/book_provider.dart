import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  final StorageService _storageService = StorageService();

  List<Book> _books = [];
  List<Book> _myBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Book> get books => _filteredBooks;
  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  // Initialize books stream
  void initializeBooksStream() {
    _bookService.getAllBooks().listen(
      (books) {
        _books = books;
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Initialize user books stream
  void initializeMyBooksStream(String userId) {
    _bookService
        .getBooksByOwner(userId)
        .listen(
          (books) {
            _myBooks = books;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Apply filters
  void _applyFilters() {
    _filteredBooks = _books.where((book) {
      // Category filter
      final categoryMatch =
          _selectedCategory == 'All' || book.category == _selectedCategory;

      // Search filter
      final searchMatch =
          _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Create book
  Future<bool> createBook({
    required String title,
    required String author,
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
    required String category,
    required String condition,
    String? description,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? imageUrl;

      // Create book first to get ID
      final book = Book(
        id: '', // Will be set by Firestore
        title: title,
        author: author,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerEmail: ownerEmail,
        category: category,
        condition: condition,
        description: description,
        datePosted: DateTime.now(),
      );

      final bookId = await _bookService.createBook(book);

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _storageService.uploadBookImage(imageFile, bookId);
        await _bookService.updateBook(bookId, {'imageUrl': imageUrl});
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update book
  Future<bool> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? category,
    String? condition,
    String? description,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (author != null) updates['author'] = author;
      if (category != null) updates['category'] = category;
      if (condition != null) updates['condition'] = condition;
      if (description != null) updates['description'] = description;

      // Upload new image if provided
      if (imageFile != null) {
        final imageUrl = await _storageService.uploadBookImage(
          imageFile,
          bookId,
        );
        updates['imageUrl'] = imageUrl;
      }

      await _bookService.updateBook(bookId, updates);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete book
  Future<bool> deleteBook(String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Delete image from storage
      await _storageService.deleteBookImage(bookId);

      // Delete book from Firestore
      await _bookService.deleteBook(bookId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update book status
  Future<bool> updateBookStatus(String bookId, String status) async {
    try {
      await _bookService.updateBookStatus(bookId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get book by ID
  Future<Book?> getBook(String bookId) async {
    try {
      return await _bookService.getBook(bookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      return await _storageService.pickImageFromGallery();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      return await _storageService.pickImageFromCamera();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

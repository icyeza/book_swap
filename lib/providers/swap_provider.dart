import 'package:flutter/material.dart';
import '../models/swap_offer.dart';
import '../services/swap_service.dart';
import '../services/book_service.dart';

class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();
  final BookService _bookService = BookService();

  List<SwapOffer> _requestedSwaps = [];
  List<SwapOffer> _receivedSwaps = [];
  bool _isLoading = false;
  String? _error;

  List<SwapOffer> get requestedSwaps => _requestedSwaps;
  List<SwapOffer> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize requested swaps stream
  void initializeRequestedSwapsStream(String userId) {
    _swapService
        .getRequestedSwaps(userId)
        .listen(
          (swaps) {
            _requestedSwaps = swaps;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Initialize received swaps stream
  void initializeReceivedSwapsStream(String userId) {
    _swapService
        .getReceivedSwaps(userId)
        .listen(
          (swaps) {
            _receivedSwaps = swaps;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Create swap offer
  Future<String?> createSwapOffer({
    required String requestedBookId,
    required String offeredBookId,
    required String requesterId,
    required String requesterName,
    required String ownerId,
    required String ownerName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if swap already exists
      final hasActiveSwap = await _swapService.hasActivSwapOffer(
        requestedBookId,
        requesterId,
      );

      if (hasActiveSwap) {
        _error = 'You already have a pending swap offer for this book';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final swapOffer = SwapOffer(
        id: '',
        requestedBookId: requestedBookId,
        offeredBookId: offeredBookId,
        requesterId: requesterId,
        requesterName: requesterName,
        ownerId: ownerId,
        ownerName: ownerName,
        createdAt: DateTime.now(),
      );

      final offerId = await _swapService.createSwapOffer(swapOffer);

      // Update both books' status to pending
      await _bookService.updateBookStatus(requestedBookId, 'pending');
      await _bookService.updateBookStatus(offeredBookId, 'pending');

      _isLoading = false;
      notifyListeners();
      return offerId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Accept swap offer
  Future<bool> acceptSwapOffer(String offerId, SwapOffer offer) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the book details before swapping to access owner emails
      final requestedBook = await _bookService.getBook(offer.requestedBookId);
      final offeredBook = await _bookService.getBook(offer.offeredBookId);

      if (requestedBook == null || offeredBook == null) {
        throw Exception('Books not found');
      }

      // Swap the book ownership
      // The requester gets the requested book (owner's book)
      await _bookService.transferBookOwnership(
        offer.requestedBookId,
        offer.requesterId,
        offer.requesterName,
        offeredBook
            .ownerEmail, // Use the offered book owner's email (the requester)
      );

      // The owner gets the offered book (requester's book)
      await _bookService.transferBookOwnership(
        offer.offeredBookId,
        offer.ownerId,
        offer.ownerName,
        requestedBook
            .ownerEmail, // Use the requested book owner's email (the receiver)
      );

      // Update swap offer status
      await _swapService.acceptSwapOffer(offerId);

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

  // Reject swap offer
  Future<bool> rejectSwapOffer(String offerId, SwapOffer offer) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _swapService.rejectSwapOffer(offerId);

      // Return books to available status
      await _bookService.updateBookStatus(offer.requestedBookId, 'available');
      await _bookService.updateBookStatus(offer.offeredBookId, 'available');

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

  // Cancel swap offer
  Future<bool> cancelSwapOffer(String offerId, SwapOffer offer) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _swapService.cancelSwapOffer(offerId);

      // Return books to available status
      await _bookService.updateBookStatus(offer.requestedBookId, 'available');
      await _bookService.updateBookStatus(offer.offeredBookId, 'available');

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

  // Complete swap
  Future<bool> completeSwap(String offerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _swapService.completeSwap(offerId);

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

  // Link chat to swap
  Future<bool> linkChatToSwap(String offerId, String chatId) async {
    try {
      await _swapService.linkChatToSwap(offerId, chatId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get pending swaps count
  Future<int> getPendingSwapsCount(String userId) async {
    try {
      return await _swapService.getPendingSwapsCount(userId);
    } catch (e) {
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

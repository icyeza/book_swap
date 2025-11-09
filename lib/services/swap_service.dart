import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_offer.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'swap_offers';

  // Create a new swap offer
  Future<String> createSwapOffer(SwapOffer offer) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(offer.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create swap offer: $e');
    }
  }

  // Get swap offers for a user (as requester or owner)
  Stream<List<SwapOffer>> getUserSwapOffers(String userId) {
    return _firestore
        .collection(_collection)
        .where('participantIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList(),
        );
  }

  // Get swap offers where user is the requester
  Stream<List<SwapOffer>> getRequestedSwaps(String userId) {
    return _firestore
        .collection(_collection)
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList(),
        );
  }

  // Get swap offers where user is the owner
  Stream<List<SwapOffer>> getReceivedSwaps(String userId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList(),
        );
  }

  // Get a single swap offer
  Future<SwapOffer?> getSwapOffer(String offerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(offerId).get();
      if (doc.exists) {
        return SwapOffer.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get swap offer: $e');
    }
  }

  // Get swap offer stream
  Stream<SwapOffer?> getSwapOfferStream(String offerId) {
    return _firestore
        .collection(_collection)
        .doc(offerId)
        .snapshots()
        .map((doc) => doc.exists ? SwapOffer.fromFirestore(doc) : null);
  }

  // Update swap offer status
  Future<void> updateSwapOfferStatus(String offerId, String status) async {
    try {
      await _firestore.collection(_collection).doc(offerId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update swap offer status: $e');
    }
  }

  // Accept swap offer
  Future<void> acceptSwapOffer(String offerId) async {
    await updateSwapOfferStatus(offerId, 'accepted');
  }

  // Reject swap offer
  Future<void> rejectSwapOffer(String offerId) async {
    await updateSwapOfferStatus(offerId, 'rejected');
  }

  // Complete swap
  Future<void> completeSwap(String offerId) async {
    await updateSwapOfferStatus(offerId, 'completed');
  }

  // Cancel swap offer
  Future<void> cancelSwapOffer(String offerId) async {
    try {
      await _firestore.collection(_collection).doc(offerId).delete();
    } catch (e) {
      throw Exception('Failed to cancel swap offer: $e');
    }
  }

  // Link chat to swap offer
  Future<void> linkChatToSwap(String offerId, String chatId) async {
    try {
      await _firestore.collection(_collection).doc(offerId).update({
        'chatId': chatId,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to link chat to swap: $e');
    }
  }

  // Get pending swaps count for user
  Future<int> getPendingSwapsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get pending swaps count: $e');
    }
  }

  // Check if swap offer exists for a book
  Future<bool> hasActivSwapOffer(String bookId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('requestedBookId', isEqualTo: bookId)
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

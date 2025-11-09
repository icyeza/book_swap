import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatsCollection = 'chats';
  final String _messagesCollection = 'messages';

  // Create or get existing chat
  Future<String> createOrGetChat({
    required List<String> participantIds,
    required List<String> participantNames,
    String? swapOfferId,
  }) async {
    try {
      // Check if chat already exists between these participants
      final existingChats = await _firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContainsAny: [participantIds.first])
          .get();

      for (var doc in existingChats.docs) {
        final chat = Chat.fromFirestore(doc);
        if (chat.participantIds.toSet().containsAll(participantIds.toSet()) &&
            participantIds.toSet().containsAll(chat.participantIds.toSet())) {
          return doc.id;
        }
      }

      // Create new chat if doesn't exist
      final chat = Chat(
        id: '',
        participantIds: participantIds,
        participantNames: participantNames,
        createdAt: DateTime.now(),
        swapOfferId: swapOfferId,
      );

      final docRef = await _firestore
          .collection(_chatsCollection)
          .add(chat.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Get user chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection(_chatsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList(),
        );
  }

  // Get chat by ID
  Future<Chat?> getChat(String chatId) async {
    try {
      final doc = await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .get();
      if (doc.exists) {
        return Chat.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Get chat stream
  Stream<Chat?> getChatStream(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? Chat.fromFirestore(doc) : null);
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      // Create message
      final chatMessage = ChatMessage(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
      );

      // Add message to subcollection
      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesCollection)
          .add(chatMessage.toFirestore());

      // Update chat with last message info
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSenderId': senderId,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a chat
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesCollection)
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesCollection)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messages = await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesCollection)
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Delete the chat document
      await _firestore.collection(_chatsCollection).doc(chatId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }
}

import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Chat> _chats = [];
  Map<String, List<ChatMessage>> _chatMessages = {};
  bool _isLoading = false;
  String? _error;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get messages for a specific chat
  List<ChatMessage> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  // Initialize user chats stream
  void initializeChatsStream(String userId) {
    _chatService
        .getUserChats(userId)
        .listen(
          (chats) {
            _chats = chats;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Initialize messages stream for a chat
  void initializeMessagesStream(String chatId) {
    _chatService
        .getChatMessages(chatId)
        .listen(
          (messages) {
            _chatMessages[chatId] = messages;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Create or get chat
  Future<String?> createOrGetChat({
    required List<String> participantIds,
    required List<String> participantNames,
    String? swapOfferId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final chatId = await _chatService.createOrGetChat(
        participantIds: participantIds,
        participantNames: participantNames,
        swapOfferId: swapOfferId,
      );

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get chat
  Future<Chat?> getChat(String chatId) async {
    try {
      return await _chatService.getChat(chatId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _chatService.markMessageAsRead(chatId, messageId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      return await _chatService.getUnreadMessageCount(chatId, userId);
    } catch (e) {
      return 0;
    }
  }

  // Delete chat
  Future<bool> deleteChat(String chatId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _chatService.deleteChat(chatId);
      _chatMessages.remove(chatId);

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

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose messages stream for a chat
  void disposeMessagesStream(String chatId) {
    _chatMessages.remove(chatId);
  }
}

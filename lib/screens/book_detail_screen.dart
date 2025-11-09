import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/status_chip.dart';
import 'post_book_screen.dart';

class ChatDetailArguments {
  final String chatId;
  final String participantName;

  ChatDetailArguments({required this.chatId, required this.participantName});
}

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  static const Color _bg = Color(0xFF0B1026);
  static const Color _accent = Color(0xFFF1C64A);
  static const Color _cardBg = Color(0xFF1A1F3A);

  Future<void> _requestSwap(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null || authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request a swap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get user's available books
    final myBooks = bookProvider.myBooks.where((b) => b.isAvailable).toList();

    if (myBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to post an available book first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show book selection dialog
    final selectedBook = await showDialog<Book>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text(
          'Select Your Book to Swap',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: myBooks.length,
            itemBuilder: (context, index) {
              final myBook = myBooks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _accent.withValues(alpha: 0.3),
                  child: Icon(Icons.book, color: _accent),
                ),
                title: Text(
                  myBook.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  myBook.author,
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => Navigator.pop(context, myBook),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedBook == null) return;

    // Create swap offer
    final offerId = await swapProvider.createSwapOffer(
      requestedBookId: book.id,
      offeredBookId: selectedBook.id,
      requesterId: authProvider.currentUserId!,
      requesterName: authProvider.userModel!.displayName,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
    );

    if (offerId != null) {
      // Create chat with owner
      await chatProvider.createOrGetChat(
        participantIds: [authProvider.currentUserId!, book.ownerId],
        participantNames: [authProvider.userModel!.displayName, book.ownerName],
        swapOfferId: offerId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              swapProvider.error ??
                  'Failed to send swap request. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _messageOwner(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null || authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to message the owner'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create or get existing chat
    final chatId = await chatProvider.createOrGetChat(
      participantIds: [authProvider.currentUserId!, book.ownerId],
      participantNames: [authProvider.userModel!.displayName, book.ownerName],
    );

    if (chatId != null && context.mounted) {
      // Navigate to chat detail screen
      // Assuming you have a route setup for chat detail
      Navigator.pushNamed(
        context,
        '/chat-detail',
        arguments: ChatDetailArguments(
          chatId: chatId,
          participantName: book.ownerName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwnBook = authProvider.currentUserId == book.ownerId;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isOwnBook)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostBookPage(bookToEdit: book),
                  ),
                );
              },
              tooltip: 'Edit Book',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          if (!isOwnBook)
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // TODO: Implement favorite
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              width: double.infinity,
              height: 280,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: book.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        book.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 80,
                                color: Colors.white30,
                              ),
                            ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 80,
                        color: Colors.white30,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Book Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Condition
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusChip(label: book.condition),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Author
                  Text(
                    'by ${book.author}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      book.category,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 24),

                  // Owner Info Section
                  const Text(
                    'Owner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _accent,
                        child: Text(
                          book.ownerName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.ownerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              book.ownerEmail,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 24),

                  // Description Section
                  if (book.description != null &&
                      book.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 24),
                  ],

                  // Posted Info
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.white60),
                      const SizedBox(width: 8),
                      Text(
                        'Posted ${book.timeAgo}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        book.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: book.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book.isAvailable ? 'Available' : 'Not Available',
                        style: TextStyle(
                          color: book.isAvailable ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isOwnBook
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bg,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _messageOwner(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _accent, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Message',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: book.isAvailable
                          ? ElevatedButton(
                              onPressed: () => _requestSwap(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Request Swap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Not Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

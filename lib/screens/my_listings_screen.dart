import 'package:book_swap/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../widgets/search_text_field.dart';
import '../widgets/book_listing_card.dart';
import '../models/swap_offer.dart';
import 'book_detail_screen.dart';
import 'post_book_screen.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF0B1026);
  static const Color _accent = Color(0xFFF1C64A);
  static const Color _cardBg = Color(0xFF1A1F3A);

  late TabController _tabController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addNewBook() {
    Navigator.pushNamed(context, '/post-book');
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final swapProvider = Provider.of<SwapProvider>(context);
    final myBooks = bookProvider.myBooks;

    // Filter books based on search
    final filteredBooks = searchQuery.isEmpty
        ? myBooks
        : myBooks.where((book) {
            return book.title.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                book.author.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Listings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Books'),
            Tab(text: 'Sent Offers'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Books Tab
          _buildMyBooksTab(filteredBooks, bookProvider),
          // Sent Offers Tab
          _buildSentOffersTab(swapProvider),
          // Received Offers Tab
          _buildReceivedOffersTab(swapProvider, bookProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBook,
        backgroundColor: _accent,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildMyBooksTab(List myBooks, BookProvider bookProvider) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchTextField(
            hintText: 'Search my books...',
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
        ),
        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${myBooks.length} ${myBooks.length == 1 ? 'Book' : 'Books'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${myBooks.where((b) => b.isAvailable).length} Available',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        // Listings
        Expanded(
          child: myBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? 'No books listed yet'
                            : 'No books found',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 18,
                        ),
                      ),
                      if (searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first book',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myBooks.length,
                  itemBuilder: (context, index) {
                    final book = myBooks[index];
                    return Dismissible(
                      key: Key(book.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: _cardBg,
                            title: const Text(
                              'Delete Book',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this book?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        bookProvider.deleteBook(book.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Book deleted'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: BookListingCard(
                        title: book.title,
                        author: book.author,
                        status: book.condition,
                        timePosted: book.timeAgo,
                        imageUrl: book.imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostBookPage(bookToEdit: book),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSentOffersTab(SwapProvider swapProvider) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sentOffers = swapProvider.requestedSwaps;
    final filteredSentOffers = sentOffers
        .where((offer) => offer.requesterId == authProvider.currentUserId!)
        .toList();

    return filteredSentOffers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No sent offers',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sentOffers.length,
            itemBuilder: (context, index) {
              final offer = sentOffers[index];
              return _buildSwapOfferCard(offer, true, swapProvider);
            },
          );
  }

  Widget _buildReceivedOffersTab(
    SwapProvider swapProvider,
    BookProvider bookProvider,
  ) {
    final receivedOffers = swapProvider.receivedSwaps;
    final authProvider = Provider.of<AuthProvider>(context);
    final filteredReceivedOffers = receivedOffers
        .where((offer) => offer.requesterId != authProvider.currentUserId!)
        .toList();

    return filteredReceivedOffers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No received offers',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receivedOffers.length,
            itemBuilder: (context, index) {
              final offer = receivedOffers[index];
              return _buildSwapOfferCard(offer, false, swapProvider);
            },
          );
  }

  Widget _buildSwapOfferCard(
    SwapOffer offer,
    bool isSent,
    SwapProvider swapProvider,
  ) {
    Color statusColor;
    switch (offer.status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isSent
                      ? 'To: ${offer.ownerName}'
                      : 'From: ${offer.requesterName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Book swap details
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              bookProvider.getBook(offer.requestedBookId),
              bookProvider.getBook(offer.offeredBookId),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Text(
                  'Loading book details...',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                );
              }

              final requestedBook = snapshot.data![0];
              final offeredBook = snapshot.data![1];

              return Column(
                children: [
                  // Offered book (what they're giving)
                  _buildBookPreview(
                    title: offeredBook?.title ?? 'Unknown',
                    author: offeredBook?.author ?? 'Unknown',
                    label: isSent ? 'Your Book' : 'They Offer',
                    labelColor: Colors.blue,
                  ),

                  // Swap icon
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.swap_horiz,
                            color: _accent,
                            size: 24,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                  ),

                  // Requested book (what they want)
                  _buildBookPreview(
                    title: requestedBook?.title ?? 'Unknown',
                    author: requestedBook?.author ?? 'Unknown',
                    label: isSent ? 'They Have' : 'Your Book',
                    labelColor: Colors.green,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          Text(
            'Created: ${_formatDate(offer.createdAt)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          if (!isSent && offer.status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await swapProvider.acceptSwapOffer(
                        offer.id,
                        offer,
                      );
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Swap offer accepted!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await swapProvider.rejectSwapOffer(
                        offer.id,
                        offer,
                      );
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Swap offer rejected'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
          if (isSent && offer.status == 'pending') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _cardBg,
                      title: const Text(
                        'Cancel Offer',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to cancel this swap offer?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    final success = await swapProvider.cancelSwapOffer(
                      offer.id,
                      offer,
                    );
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Swap offer cancelled'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Offer'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookPreview({
    required String title,
    required String author,
    required String label,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: labelColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.book, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  author,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}


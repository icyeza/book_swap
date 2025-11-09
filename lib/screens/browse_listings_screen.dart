import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_listing_card.dart';
import '../widgets/search_text_field.dart';
import '../widgets/category_filter_row.dart';
import '../constants/dummy_data.dart';
import 'book_detail_screen.dart';

class BrowseListingsPage extends StatefulWidget {
  const BrowseListingsPage({super.key});

  @override
  State<BrowseListingsPage> createState() => _BrowseListingsPageState();
}

class _BrowseListingsPageState extends State<BrowseListingsPage> {
  static const Color _bg = Color(0xFF0B1026);

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final books = bookProvider.books;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Browse Listings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchTextField(
              hintText: 'Search books...',
              onChanged: (query) {
                bookProvider.setSearchQuery(query);
              },
            ),
          ),
          // Categories
          CategoryFilterRow(
            categories: getAllCategories(),
            selectedCategory: bookProvider.selectedCategory,
            onCategorySelected: (category) {
              bookProvider.setCategory(category);
            },
          ),
          // Listings
          Expanded(
            child: bookProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to post a book!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      // Don't show user's own books in browse
                      if (book.ownerId == authProvider.currentUserId) {
                        return const SizedBox.shrink();
                      }
                      return BookListingCard(
                        title: book.title,
                        author: book.author,
                        status: book.condition,
                        timePosted: book.timeAgo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'browse_listings_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BrowseListingsPage(),
    const MyListingsPage(),
    const ChatsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Initialize streams if user is authenticated
    if (authProvider.currentUserId != null) {
      bookProvider.initializeBooksStream();
      bookProvider.initializeMyBooksStream(authProvider.currentUserId!);
      swapProvider.initializeRequestedSwapsStream(authProvider.currentUserId!);
      swapProvider.initializeReceivedSwapsStream(authProvider.currentUserId!);
      chatProvider.initializeChatsStream(authProvider.currentUserId!);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

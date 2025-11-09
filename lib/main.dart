import 'package:book_swap/screens/book_detail_screen.dart';
import 'package:book_swap/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/swap_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/browse_listings_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/post_book_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SwapProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'BookSwap',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF0B1026),
              brightness: Brightness.dark,
            ),
            home: authProvider.isAuthenticated
                ? const HomeScreen()
                : const WelcomeScreen(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignUpPage(),
              '/home': (context) => const HomeScreen(),
              '/browse': (context) => const BrowseListingsPage(),
              '/my-listings': (context) => const MyListingsPage(),
              '/post-book': (context) => const PostBookPage(),
              '/chats': (context) => const ChatsScreen(),
              '/chat-detail': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as ChatDetailArguments;
                return ChatDetailScreen(
                  chatId: args.chatId,
                  participantName: args.participantName,
                );
              },
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/message_provider.dart';
import 'providers/recipient_provider.dart';
import 'services/notification_service.dart';
import 'services/dead_mans_switch_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/create_message_screen.dart';
import 'screens/recipients/recipients_screen.dart';
import 'screens/recipients/add_recipient_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/check_in/check_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize services
  await NotificationService.initialize();
  await DeadMansSwitchService.initialize();
  
  runApp(const AfterWordsApp());
}

class AfterWordsApp extends StatelessWidget {
  const AfterWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => RecipientProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'AfterWords',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E3440),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E3440),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        
        // Show splash screen while loading
        if (isLoading && state.uri.toString() == '/splash') {
          return null;
        }
        
        // Redirect to login if not authenticated
        if (!isAuthenticated && !_isAuthRoute(state.uri.toString())) {
          return '/login';
        }
        
        // Redirect to home if authenticated and on auth routes
        if (isAuthenticated && _isAuthRoute(state.uri.toString())) {
          return '/home';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/messages/create',
          builder: (context, state) => const CreateMessageScreen(),
        ),
        GoRoute(
          path: '/recipients',
          builder: (context, state) => const RecipientsScreen(),
        ),
        GoRoute(
          path: '/recipients/add',
          builder: (context, state) => const AddRecipientScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/check-in',
          builder: (context, state) => const CheckInScreen(),
        ),
      ],
    );
  }

  bool _isAuthRoute(String location) {
    return location == '/login' || 
           location == '/register' || 
           location == '/splash';
  }
}
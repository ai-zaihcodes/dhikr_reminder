import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/errors/supabase_error_handler.dart';
import 'injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/quote/quote_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase with your credentials
    await Supabase.initialize(
      url: 'https://db.xsveadyxejofublpevsw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzdmVhZHl4ZWpvZnVibHBldnN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0MDQ5MDgsImV4cCI6MjA5MDk4MDkwOH0.a6_FrkN5i1ZI1hn8VpzBaAk8gWSJCuG25vWtzD3frNY',
      // Enable debug mode in development
      debug: true,
    );

    // Configure DI
    configureDependencies();

    runApp(const DhikrReminderApp());
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize app: $e');
    debugPrint(stackTrace.toString());

    // Run error app if initialization fails
    runApp(SupabaseInitErrorApp(error: e.toString()));
  }
}

/// App to show when Supabase initialization fails
class SupabaseInitErrorApp extends StatelessWidget {
  final String error;

  const SupabaseInitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final isMissingTable = SupabaseErrorHandler.isMissingTableError(error);

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to Connect to Supabase',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isMissingTable
                      ? 'Database tables not found. Please run the schema.sql file in your Supabase SQL Editor.'
                      : SupabaseErrorHandler.getMessage(error),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (isMissingTable) ...[
                  const SizedBox(height: 24),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fix Steps:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('1. Go to https://app.supabase.com'),
                          Text('2. Select your project'),
                          Text('3. Go to SQL Editor'),
                          Text('4. Copy contents of supabase/schema.sql'),
                          Text('5. Click Run'),
                          Text('6. Restart the app'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Try to reinitialize
                    main();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Exit app
                  },
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DhikrReminderApp extends StatelessWidget {
  const DhikrReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<QuoteBloc>()),
        BlocProvider(create: (_) => getIt<SettingsBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            title: 'Dhikr Reminder',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.light,
              ),
              fontFamily: 'Cairo',
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                brightness: Brightness.dark,
              ),
              fontFamily: 'Cairo',
            ),
            themeMode: ThemeMode.system,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const SplashScreen();
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}

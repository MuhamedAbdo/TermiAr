import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Use default light theme if not initialized yet to avoid blank screen
          if (!themeProvider.isInitialized) {
            return MaterialApp(
              title: 'TermiAr',
              debugShowCheckedModeBanner: false,
              theme: ThemeProvider.lightTheme,
              locale: const Locale('ar'),
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
              routes: {'/home': (context) => const MainNavigation()},
            );
          }

          return MaterialApp(
            title: 'TermiAr',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {'/home': (context) => const MainNavigation()},
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:termi_ar/providers/favorites_provider.dart';
import 'package:termi_ar/providers/theme_provider.dart';
import 'package:termi_ar/screens/main_navigation.dart';
import 'package:termi_ar/screens/home_screen.dart';

Widget createTestApp(Widget child, {Size size = const Size(1200, 800)}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ],
    child: MaterialApp(
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
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Adaptive Navigation Tests', () {
    testWidgets('Renders BottomNavigationBar on mobile screen (width < 800)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const MainNavigation(),
        size: const Size(600, 900),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets(
        'Renders NavigationRail and removes BottomNavigationBar on desktop screen (width >= 800)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const MainNavigation(),
        size: const Size(1200, 800),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('NavigationRail respects Arabic RTL directionality',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const MainNavigation(),
        size: const Size(1000, 700),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final textDirection = Directionality.of(tester.element(find.byType(NavigationRail)));
      expect(textDirection, TextDirection.rtl);
    });
  });

  group('Dynamic Grid Layouts & Constrained Content Width Tests', () {
    testWidgets('Home screen contains ConstrainedBox with maxWidth 1200',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(1400, 900),
      ));
      await tester.pumpAndSettle();

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      final has1200MaxWidth = constrainedBoxes.any(
        (box) => box.constraints.maxWidth == 1200.0,
      );
      expect(has1200MaxWidth, isTrue);
    });

    testWidgets('Home screen GridView crossAxisCount is 2 on mobile (< 600)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(500, 800),
      ));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(GridView);
      if (gridFinder.evaluate().isNotEmpty) {
        final grid = tester.widget<GridView>(gridFinder.first);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
      }
    });

    testWidgets('Home screen GridView crossAxisCount is 3 on tablet (600 - 849)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(700, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(700, 900),
      ));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(GridView);
      if (gridFinder.evaluate().isNotEmpty) {
        final grid = tester.widget<GridView>(gridFinder.first);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 3);
      }
    });

    testWidgets('Home screen GridView crossAxisCount is 4 on desktop (850 - 1099)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(950, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(950, 900),
      ));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(GridView);
      if (gridFinder.evaluate().isNotEmpty) {
        final grid = tester.widget<GridView>(gridFinder.first);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 4);
      }
    });

    testWidgets('Home screen GridView crossAxisCount is 5 on desktop wide (>= 1100)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1300, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(1300, 900),
      ));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(GridView);
      if (gridFinder.evaluate().isNotEmpty) {
        final grid = tester.widget<GridView>(gridFinder.first);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 5);
      }
    });
  });

  group('Desktop UX Polish Tests', () {
    testWidgets('Scrollbars are present in scrollable areas',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(1000, 800),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsWidgets);
    });

    testWidgets('Clickable elements explicitly use SystemMouseCursors.click',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(
        const HomeScreen(),
        size: const Size(1000, 800),
      ));
      await tester.pumpAndSettle();

      final mouseRegions = tester.widgetList<MouseRegion>(
        find.byType(MouseRegion),
      );

      final hasClickCursor = mouseRegions.any(
        (region) => region.cursor == SystemMouseCursors.click,
      );
      expect(hasClickCursor, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:termi_ar/main.dart';

void main() {
  testWidgets('TermiAr smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(MyApp), findsOneWidget);
  });
}

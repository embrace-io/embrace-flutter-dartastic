import 'package:flutter_test/flutter_test.dart';

import 'package:embrace_flutter_dartastic/main.dart';

void main() {
  testWidgets('App renders with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Errors'), findsOneWidget);
    expect(find.text('Hello, Dartastic!'), findsOneWidget);
  });
}

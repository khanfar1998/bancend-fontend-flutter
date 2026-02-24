import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:di_example/di/injection.dart';
import 'package:di_example/main.dart';

void main() {
  testWidgets('Counter starts at 0 and increments', (WidgetTester tester) async {
    setupInjection();
    await tester.pumpWidget(const DiExampleApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

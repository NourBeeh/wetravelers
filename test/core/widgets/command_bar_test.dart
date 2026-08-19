import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/widgets/command_bar/command_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('CommandBar', () {
    testWidgets('Ask button submits trimmed text and clears the field',
        (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(wrap(CommandBar(onSubmitted: submitted.add)));

      await tester.enterText(find.byType(TextField), '  plan a trip  ');
      await tester.tap(find.widgetWithText(FilledButton, 'Ask'));
      await tester.pump();

      expect(submitted, ['plan a trip']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('keyboard submit also submits the typed text', (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(wrap(CommandBar(onSubmitted: submitted.add)));

      await tester.enterText(find.byType(TextField), 'cheapest flight');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, ['cheapest flight']);
    });

    testWidgets('empty or whitespace-only input does not fire the callback',
        (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(wrap(CommandBar(onSubmitted: submitted.add)));

      await tester.tap(find.widgetWithText(FilledButton, 'Ask'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.widgetWithText(FilledButton, 'Ask'));
      await tester.pump();

      expect(submitted, isEmpty);
    });
  });
}
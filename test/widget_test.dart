import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/injection.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('app launches and shows the loading state while checking session',
      (WidgetTester tester) async {
    final deps = AppDependencies.build();

    await tester.pumpWidget(MyApp(deps: deps));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('MovieApp'), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uyoung_app/app/app.dart';

void main() {
  testWidgets('app renders entry page', (tester) async {
    await tester.pumpWidget(const UyoungApp());

    expect(find.text('Uyoung App'), findsOneWidget);
  });
}

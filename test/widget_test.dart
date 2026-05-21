import 'package:flutter_test/flutter_test.dart';
import 'package:pc_control/main.dart';

void main() {
  testWidgets('应用启动测试', (WidgetTester tester) async {
    await tester.pumpWidget(const PcControlApp());
    expect(find.text('远程开机控制'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/utils/loader/txt.dart';

void main() {
  group('Testing TxtLoader', () {
    Book book = Book(id:"id", name:"name", extension: "", localPath: "localpath");
    BookConfig bookConfig = BookConfig(300, 300);
    TxtLoader txtLoader = TxtLoader(book,bookConfig);
    test('match chapter test', () async {
      expect(txtLoader.matchTitle("第一"), null);
      expect(
          txtLoader.matchTitle(
              "“是谁说魔族军队很强的？”罗杰副旗本（旗本：家族职衔名称）得意的望着山脚下如同潮水般溃退的魔族精锐部队，“看起来似乎我还更强上一点。”"),
          null);
      expect(txtLoader.matchTitle("第一章部"), null);
      //
      expect(txtLoader.matchTitle("  第一部"), "第一部");
      expect(txtLoader.matchTitle("\n第1章  红杏出墙"), "第1章  红杏出墙");
      expect(txtLoader.matchTitle("第一部 紫川三杰"), "第一部 紫川三杰");
      expect(txtLoader.matchTitle("第1章 - 居然会赢"), "第1章 - 居然会赢");
      expect(txtLoader.matchTitle("第12345章 - 居然会赢"), "第12345章 - 居然会赢");
      expect(
          txtLoader.matchTitle("第一万二千三百四十五章 - 居然会赢"), "第一万二千三百四十五章 - 居然会赢");
      expect(
          txtLoader.matchTitle("   第一千一百零三章 - 居然会赢"), "第一千一百零三章 - 居然会赢");

      // await tester.pumpWidget(const MyApp());
      //
      // // Verify that our counter starts at 0.
      // expect(find.text('0'), findsOneWidget);
      // expect(find.text('1'), findsNothing);
      //
      // // Tap the '+' icon and trigger a frame.
      // await tester.tap(find.byIcon(Icons.add));
      // await tester.pump();
      //
      // // Verify that our counter has incremented.
      // expect(find.text('0'), findsNothing);
      // expect(find.text('1'), findsOneWidget);
    });
  });
}

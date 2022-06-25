import 'package:flutter/material.dart';
import 'package:shosai/utils/log.dart';

void main() async {
  // String decoded = gbk
  //     .decode([0xA1, 0xE8, 0xA1, 0xEC, 0xA1, 0xA7, 0xA1, 0xE3, 0xA1, 0xC0]);
  TextPainter textPainter = TextPainter(
    // locale: Localizations.localeOf(navKey.currentState!.context),
    textScaleFactor: 1,
    maxLines: 2,
    textDirection: TextDirection.ltr,
  );

  /// 标题样式
  TextStyle style = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    // backgroundColor: Colors.red,
  );
  String line =
      "史蒂夫哈可视电话封口机阿萨德和付款计划史蒂夫哈可视电话封口机阿萨德和付款计划史蒂夫哈可视电话封口机阿萨德和付款计划史蒂夫哈可视电话封口机阿萨德和付款计划";
  measure(textPainter, line, style, 233);
}

void measure(
    TextPainter textPainter, String line, TextStyle style, double maxWidth) {
  textPainter.text = TextSpan(text: line, style: style);
  textPainter.layout(maxWidth: maxWidth);
  MyLog.d(
      "TxtLoader measure: ${textPainter.width}x${textPainter.height}； ${textPainter.minIntrinsicWidth}/${textPainter.maxIntrinsicWidth}； out: ${textPainter.didExceedMaxLines} >> $line");
}

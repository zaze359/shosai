import 'package:flutter/material.dart';
import 'package:shosai/data/book_config.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/log.dart';

/// 阅读单页界面
class SinglePageView extends StatelessWidget {
  PageState pageState;

  SinglePageView(this.pageState, {super.key});

  @override
  Widget build(BuildContext context) {
    MyLog.d("_SinglePageView", "build");
    Widget child;
    if (pageState.lines.length == 1 && pageState.lines[0].isTitle) {
      PageLine pageLine = pageState.lines[0];
      child = Center(
        child: Text(pageLine.text, style: pageLine.style),
      );
    } else {
      child = Column(
        mainAxisAlignment: pageState.mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pageState.lines.map((e) {
          return Text(e.text, style: e.style);
        }).toList(),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        bookConfig.paddingLeft,
        bookConfig.paddingTop,
        bookConfig.paddingRight,
        bookConfig.paddingBottom,
      ),
      child: child,
    );
    // Text.rich + TextSpan。存在换行点对不上点问题。
    // return Text.rich(
    //   TextSpan(
    //     style: TextStyle(
    //       fontSize: 0,
    //     ),
    //     children: pageState.lines.map((e) {
    //       return TextSpan(text: e.text, style: e.style);
    //     }).toList(),
    //   ),
    //   textAlign: TextAlign.left,
    // );
  }
}

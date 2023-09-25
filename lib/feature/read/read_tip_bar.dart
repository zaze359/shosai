import 'package:flutter/material.dart';
import 'package:shosai/core/model/book_state.dart';

/// 阅读情况的提示栏
class ReadTipBar extends StatelessWidget {
  final PageState pageState;

  static double readTipBarHeight = 40;

  const ReadTipBar(this.pageState, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ReadTipBar.readTipBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Divider(
            color: Colors.black38,
            height: 1,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "${pageState.bookName}  ",
                            style: const TextStyle(fontSize: 14)),
                        TextSpan(
                          text: pageState.chapterTitle,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    "${pageState.pageIndex + 1}/${pageState.chapterSize}",
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

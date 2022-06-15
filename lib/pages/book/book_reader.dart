import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/controller.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/log.dart';

/// 书籍阅读界面
class BookReaderPage extends StatefulWidget {
  late BookController _bookController;

  void setBook(Book book) {
    _bookController = BookController(book);
  }

  BookReaderPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BookReaderPageState();
  }
}

class _BookReaderPageState extends State<BookReaderPage> {
  @override
  Widget build(BuildContext context) {
    Book book =
        ModalRoute.of(context)?.settings.arguments as Book? ?? Book.empty();
    widget.setBook(book);
    MyLog.d("_BookReaderPageState", "build");
    final bookControl = widget._bookController;
    return Scaffold(
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          // systemOverlayStyle: SystemUiOverlayStyle.light,
          // backgroundColor: Colors.transparent,
          // foregroundColor: Colors.transparent,
          toolbarHeight: 0,
        ),
        // SafeArea
        body: LayoutBuilder(builder: (context, boxConstraints) {
          // 获取页面尺寸
          bookControl.updateBookConfig(
              BookConfig(boxConstraints.maxWidth, boxConstraints.maxHeight));
          return Container(
            child: FutureBuilder(
              // future: _loadBook(book),
              future: bookControl.loadBookContent(),
              builder:
                  (BuildContext context, AsyncSnapshot<PageState> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text(
                      "error: ${snapshot.error}, ${snapshot.stackTrace}",
                      style: TextStyle(color: Colors.black),
                    );
                  }
                  // success
                  return _ReadView(widget._bookController);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        }));
  }
}

class _ReadView extends StatefulWidget {
  _ReadView(this._bookController);

  BookController _bookController;

  @override
  State<StatefulWidget> createState() {
    return _ReadViewState();
  }
}

class _ReadViewState extends State<_ReadView> {
  final ScrollController _controller = ScrollController();
  late Future<PageState?>? pageFuture = widget._bookController.getCurPage();

  // PageState? pageState;

  void _onPressed(String text) {
    MyLog.d("_PageTouchView", "_onPressed: $text");
    setState(() {
      switch (text) {
        case "上一页":
          // pageFuture = widget._bookController.getPrevPage();
          pageFuture = widget._bookController.getPrevPage();
          break;
        case "下一页":
          // pageFuture = widget._bookController.getNextPage();
          pageFuture = widget._bookController.getNextPage();
          break;
        case "菜单":
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // _controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.ease);
    _controller.addListener(() {
      MyLog.d("_ReadViewState", "offset: ${_controller.offset}");
      MyLog.d("_ReadViewState",
          "keepScrollOffset: 1  ${_controller.keepScrollOffset}");
    });
    return LayoutBuilder(builder: (context, boxConstraints) {
      double aspectRatio = boxConstraints.maxWidth / boxConstraints.maxHeight;
      return Stack(
        children: [
          // _SinglePageView(pageState ?? PageState()),
          FutureBuilder(
              future: pageFuture,
              builder: (context, AsyncSnapshot<PageState?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // MyLog.i(
                  //     "_ReadViewState", "pageFuture: ${snapshot.data?.lines}");
                  return _SinglePageView(snapshot.data ?? PageState());
                }
                return Text("加载中");
              }),
          GridView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: aspectRatio,
              // crossAxisSpacing: 4,
              // mainAxisSpacing: 4,
            ),
            children: [
              _TouchBlockView("上一页", _onPressed),
              _TouchBlockView("上一页", _onPressed),
              _TouchBlockView("下一页", _onPressed),
              _TouchBlockView("上一页", _onPressed),
              _TouchBlockView("菜单", _onPressed),
              _TouchBlockView("下一页", _onPressed),
              _TouchBlockView("上一页", _onPressed),
              _TouchBlockView("下一页", _onPressed),
              _TouchBlockView("下一页", _onPressed),
            ],
          )
        ],
      );
    });
  }
}

// --------------------------------------------------
class _TouchBlockView extends StatelessWidget {
  _TouchBlockView(this.text, this.onPressed);

  String text;
  Function(String text) onPressed;

  void _onPressed() {
    onPressed(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Container(
        color: Colors.transparent, // 需要设置透明，否则默认透明部分不响应事件
        child: Center(
            // child: Text(text),
            ),
      ),
    );
  }
}

// --------------------------------------------------
/// 阅读单页界面
class _SinglePageView extends StatelessWidget {
  PageState pageState;

  _SinglePageView(this.pageState);

  @override
  Widget build(BuildContext context) {
    // SelectableText
    return Text.rich(
      TextSpan(
        children: pageState.lines,
      ),
    );
  }
}

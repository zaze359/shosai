import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/controller.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

class ReadCache with ChangeNotifier, DiagnosticableTreeMixin {
  bool menuVisible = false;

  late Future<PageState?>? Function()? loadData = () {
    loadData = null;
    return bookController.loadHistoryPage();
  };

  Book? get book => bookController.book;

  BookChapter? get curChapter => bookController.curChapter;

  set book(Book? book) {
    bookController.book = book;
  }

  reload() async {
    loadData = () {
      loadData = null;
      return bookController.reload();
    };
    notifyListeners();
  }

  void prevPage() {
    MyLog.d("ReadCache", "prevPage");
    loadData = () {
      loadData = null;
      return bookController.getPrevPage();
    };
    notifyListeners();
  }

  void nextPage() {
    MyLog.d("ReadCache", "nextPage");
    loadData = () {
      loadData = null;
      return bookController.getNextPage();
    };
    notifyListeners();
  }

  void loadCurPage() {
    MyLog.d("ReadCache", "loadCurPage");
    loadData = () {
      loadData = null;
      return bookController.loadCurPage();
    };
    notifyListeners();
  }

  void prevChapter() {
    MyLog.d("ReadCache", "prevChapter");
    bookController.moveToChapter(bookController.chapterIndex - 1);
    loadCurPage();
    // refresh();
  }

  void nextChapter() {
    MyLog.d("ReadCache", "nextChapter");
    bookController.moveToChapter(bookController.chapterIndex + 1);
    loadCurPage();
    // refresh();
  }

  void showMenu() {
    MyLog.d("ReadCache", "showMenu");
    menuVisible = true;
    notifyListeners();
  }

  void closeMenu() {
    MyLog.d("ReadCache", "closeMenu");
    menuVisible = false;
    notifyListeners();
  }
}

/// 书籍阅读界面
class BookReaderPage extends StatelessWidget {
  const BookReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ReadCache>().book =
        ModalRoute.of(context)?.settings.arguments as Book?;
    MyLog.d("BookReaderPage", "build");
    return Theme(
      data: ThemeData(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // 允许菜单的AppBar显示再最上方
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  // 获取页面尺寸
                  bookConfig.updateSize(
                      boxConstraints.maxWidth, boxConstraints.maxHeight);
                  MyLog.d("BookReaderPage", "bookConfig: $bookConfig");
                  return _ReadView();
                },
              ),
            ),
            _OperatorContainer(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<ReadCache>().reload();
          },
          tooltip: 'refresh',
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _ReadView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReadViewState();
  }
}

class _ReadViewState extends State<_ReadView> {
  // final ScrollController _controller = ScrollController();
  PageState? latestPage;
  StreamSubscription? subscription;

  // Future<PageState?>? pageFuture;
  @override
  Widget build(BuildContext context) {
    MyLog.d("_ReadViewState", "build");
    // _controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.ease);
    // _controller.addListener(() {
    //   MyLog.d("_ReadViewState", "offset: ${_controller.offset}");
    //   MyLog.d("_ReadViewState",
    //       "keepScrollOffset: 1  ${_controller.keepScrollOffset}");
    // });
    // pageFuture = context.watch<ReadCache>().pageFuture;

    // return LoadingBuild<PageState?>(
    //   future: context.watch<ReadCache>().loadData?.call(),
    //   success: (context, value) {
    //     latestPage = value ?? latestPage;
    //     // context.read<ReadCache>().loadData = null;
    //     // bookController.preLoad();
    //     return _SinglePageView(latestPage ?? PageState());
    //   },
    // );
    return LoadingBuild<PageState?>.circle(
      future: context.watch<ReadCache>().loadData?.call(),
      success: (context, value) {
        latestPage = value ?? latestPage;
        // context.read<ReadCache>().loadData = null;
        // bookController.preLoad();
        return _SinglePageView(latestPage ?? PageState());
      },
    );
    // return LoadingBuild2<dynamic>(
    //   stream: bookController.a(),
    //   success: (context, value) {
    //     latestPage = value ?? latestPage;
    //     return _SinglePageView(latestPage ?? PageState());
    //   },
    // );
  }

  @override
  void initState() {
    printD("_ReadViewState", "initState");
    subscription = eventBus.on<ReadEvent>().listen((event) {
      printD("_ReadViewState", "eventBus listen: $event");
      context.read<ReadCache>().loadCurPage();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if (pageFuture != context.read<ReadCache>().pageFuture) {
    MyLog.d("_ReadViewState", "didChangeDependencies");
    super.didChangeDependencies();
    // }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    printD("_ReadViewState", "setState");
  }

  @override
  void didUpdateWidget(covariant _ReadView oldWidget) {
    printD("_ReadViewState", "didUpdateWidget");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    printD("_ReadViewState", "deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    printD("_ReadViewState", "dispose");
    subscription?.cancel();
    super.dispose();
  }
}

// --------------------------------------------------
/// 阅读单页界面
class _SinglePageView extends StatelessWidget {
  final PageState pageState;

  const _SinglePageView(this.pageState);

  @override
  Widget build(BuildContext context) {
    // SelectableText
    // var list = ;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          bookConfig.paddingLeft,
          bookConfig.paddingTop,
          bookConfig.paddingRight,
          bookConfig.paddingBottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pageState.lines.map((e) {
          return Text(e.text, style: e.style);
        }).toList(),
      ),
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

// --------------------------------------------------

class _OperatorContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OperatorContainerState();
  }
}

class _OperatorContainerState extends State<_OperatorContainer> {
  late MapEntry<String, Function> prevPage =
      MapEntry("上一页", context.read<ReadCache>().prevPage);
  late MapEntry<String, Function> nextPage =
      MapEntry("下一页", context.read<ReadCache>().nextPage);
  late MapEntry<String, Function> toggleMenu =
      MapEntry("菜单", context.read<ReadCache>().showMenu);

  @override
  Widget build(BuildContext context) {
    MyLog.d("_OperatorContainerState", "build");
    if (context.watch<ReadCache>().menuVisible) {
      return _MenuWidget();
    }
    return SafeArea(
      child: LayoutBuilder(builder: (context, boxConstraints) {
        double aspectRatio = boxConstraints.maxWidth / boxConstraints.maxHeight;
        return GridView(
          // controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: aspectRatio,
            // crossAxisSpacing: 4,
            // mainAxisSpacing: 4,
          ),
          children: [
            _TouchBlockView(prevPage, false),
            _TouchBlockView(prevPage, false),
            _TouchBlockView(nextPage, false),
            //
            _TouchBlockView(prevPage, false),
            _TouchBlockView(toggleMenu, false),
            _TouchBlockView(nextPage, false),
            //
            _TouchBlockView(prevPage, false),
            _TouchBlockView(nextPage, false),
            _TouchBlockView(nextPage, false),
          ],
        );
      }),
    );
  }
}

class _TouchBlockView extends StatelessWidget {
  const _TouchBlockView(this._map, this._showText);

  final MapEntry<String, Function> _map;
  final bool _showText;

  void _onPressed() {
    _map.value();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Container(
        color: Colors.transparent, // 需要设置透明，否则默认透明部分不响应事件
        child: Center(
          child: _showText ? Text(_map.key) : null,
        ),
      ),
    );
  }
}

class _MenuWidget extends StatefulWidget {
  final List<BottomNavigationBarItem> bottomNavigationBarItems =
      <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.toc),
      label: "目录",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: "设置",
    ),
  ];

  @override
  State<StatefulWidget> createState() {
    return _MenuState();
  }
}

class _MenuState extends State<_MenuWidget> {
  _onMenuItemSelected(int position) {
    context.read<ReadCache>().closeMenu();
    AppRoutes.pushBookTocPage(context);
  }

  void _prevChapter() {
    context.read<ReadCache>().prevChapter();
  }

  void _nextChapter() {
    context.read<ReadCache>().nextChapter();
  }

  @override
  Widget build(BuildContext context) {
    MyLog.d("_MenuState", "build");

    return Scaffold(
      // 允许内容扩展到状态栏下
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "${context.read<ReadCache>().book?.name}  "),
              TextSpan(
                text: "${context.read<ReadCache>().curChapter?.title}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<ReadCache>().closeMenu();
              },
              child: Container(
                color: Colors.transparent, // 需要设置透明，否则不响应事件
              ),
            ),
          ),
          ColoredBox(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: _prevChapter,
                  child: const Text(
                    "上一章",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: _nextChapter,
                  child: const Text(
                    "下一章",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            items: widget.bottomNavigationBarItems,
            currentIndex: 0,
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.black,
            onTap: _onMenuItemSelected,
          )
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    MyLog.d("_MenuState", "didChangeDependencies");
    super.didChangeDependencies();
  }
}

//
// class MultipleTapGestureRecognizer extends TapGestureRecognizer {
//   @override
//   void rejectGesture(int pointer) {
//     acceptGesture(pointer);
//   }
//
// }

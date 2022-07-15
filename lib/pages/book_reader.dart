import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/pages/horizontal_page.dart';
import 'package:shosai/pages/read_model.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';

/// 书籍阅读界面
class BookReaderPage extends StatelessWidget {
  const BookReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    Book? book = ModalRoute.of(context)?.settings.arguments as Book?;
    MyLog.d("BookReaderPage", "build");
    if (book == null) {
      return const Text("无法获取到书籍信息");
    }
    return Theme(
      data: ThemeData(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            return PageModel(book);
          }),
          ChangeNotifierProvider(create: (_) {
            return UIModel();
          }),
        ],
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
                child: _ReadView(),
              ),
              _MenuWidget(book)
            ],
          ),
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
  StreamSubscription? subscription;

  @override
  Widget build(BuildContext context) {
    MyLog.d("_ReadViewState", "build:");
    return const HorizontalPage();
    // return VerticalPage();
  }

  @override
  void initState() {
    printD("_ReadViewState", "initState");
    subscription = eventBus.on<ReadEvent>().listen((event) {
      printD("_ReadViewState", "eventBus listen: $event");
      context.read<PageModel>().refresh(event);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    MyLog.d("_ReadViewState", "didChangeDependencies");
    super.didChangeDependencies();
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
// --------------------------------------------------
/// 菜单栏
class _MenuWidget extends StatefulWidget {
  Book book;

  _MenuWidget(this.book);

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
    context.read<UIModel>().closeMenu();
    AppRoutes.startBookTocPage(context, widget.book);
  }

  void _prevChapter() {
    context.read<PageModel>().prevChapter();
  }

  void _nextChapter() {
    context.read<PageModel>().nextChapter();
  }

  @override
  Widget build(BuildContext context) {
    bool menuVisible = context.watch<UIModel>().menuVisible;
    MyLog.d("_MenuState", "build menuVisible: $menuVisible");
    return Offstage(
      offstage: !menuVisible,
      child: Scaffold(
        // 允许内容扩展到状态栏下
        // extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Consumer<PageModel>(
          builder: (context, cache, _) {
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "${cache.book.name}  "),
                  TextSpan(
                    text: cache.curPage.chapterTitle,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        )),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer(builder: (context, UIModel ui, _) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ui.closeMenu();
                  },
                  child: Container(
                    color: Colors.transparent, // 需要设置透明，否则不响应事件
                  ),
                ),
              );
            }),
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

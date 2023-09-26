import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/feature/read/horizontal_mode.dart';
import 'package:shosai/feature/read/book_read_vm.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/utils/utils.dart';
import 'package:shosai/widgets/loading_widget.dart';

/// 书籍阅读界面
class BookReadPage extends StatelessWidget {
  const BookReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    Book? book = ModalRoute.of(context)?.settings.arguments as Book?;
    MyLog.d("BookReaderPage", "build");
    if (book == null) {
      return const Text("无法获取到书籍信息");
    }

    return Theme(
      data: ThemeData(),
      child: ChangeNotifierProvider(
        create: (_) {
          return BookReadViewModel(book);
        },
        builder: (context, _) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            // 允许菜单的AppBar显示再最上方
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: _PermissionWidget.circle(context, book),
          );
        },
      ),
    );
  }
}

class _PermissionWidget extends LoadingBuild<bool> {
  _PermissionWidget.circle(BuildContext context, Book book)
      : super.circle(
          future: Utils.checkPermission(),
          success: (c, v) {
            if (v == true) {
              return Stack(
                children: [
                  SafeArea(
                    child: _ReadView(),
                  ),
                  _MenuWidget(book)
                ],
              );
            } else {
              // Navigator.of(context).pop();
              return const Text("请求文件读取权限");
            }
          },
        );
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
    return const HorizontalMode();
    // return VerticalPage();
  }

  @override
  void initState() {
    printD("_ReadViewState", "initState");
    subscription = eventBus.on<ReadEvent>().listen((event) {
      printD("_ReadViewState", "eventBus listen: $event");
      context.read<BookReadViewModel>().refresh(event);
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
  final Book book;

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
    context.read<BookReadViewModel>().closeMenu();
    AppRoutes.startBookTocPage(context, widget.book);
  }

  void _prevChapter() {
    context.read<BookReadViewModel>().prevChapter();
  }

  void _nextChapter() {
    context.read<BookReadViewModel>().nextChapter();
  }

  @override
  Widget build(BuildContext context) {
    bool menuVisible = context.watch<BookReadViewModel>().menuVisible;
    return Offstage(
      offstage: !menuVisible,
      child: Scaffold(
        // 允许内容扩展到状态栏下
        // extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Consumer<BookReadViewModel>(
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
            Consumer(builder: (context, BookReadViewModel ui, _) {
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
}

//
// class MultipleTapGestureRecognizer extends TapGestureRecognizer {
//   @override
//   void rejectGesture(int pointer) {
//     acceptGesture(pointer);
//   }
//
// }

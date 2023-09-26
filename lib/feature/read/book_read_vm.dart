import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_config.dart';
import 'package:shosai/core/model/book_state.dart';
import 'package:shosai/utils/controller.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';

class BookReadViewModel with ChangeNotifier, DiagnosticableTreeMixin {
  BookReadViewModel(this._book) {
    bookController.book = _book;
  }

  bool menuVisible = false;
  PageController controller = PageController();

  final Book _book;

  Book get book => _book;
  ConnectionState connectionState = ConnectionState.done;

  /// initialPage
  int initialPage = 0;

  /// 所有需要显示的页面
  List<PageState> showPages = [];

  PageState get curPage {
    if (initialPage >= showPages.length) {
      return PageState.empty();
    } else {
      return showPages[initialPage];
    }
  }

  reload() async {
    _updateState(ConnectionState.waiting);
    await bookController.reload();
    _updateState(ConnectionState.done);
  }

  ///  合并章节
  ///  0: cur; 1: next; -1: prev
  Future<List<PageState>> composeChapter(int offset) async {
    bookController.moveSomeChapter(offset);
    ChapterState? curChapter = await bookController.loadCurChapter();
    ChapterState? preChapter;
    ChapterState? nextChapter;
    showPages.clear();
    initialPage = 0;
    if (curChapter == null) {
      return showPages;
    }
    // --------------------------------------------------
    // --------------------------------------------------
    if (bookController.chapterSize <= 1) {
      // 仅有一章，直接返回
      showPages.addAll(curChapter.pages);
      return showPages;
    }
    // 加载上一章。
    preChapter = await bookController.loadPreChapter();
    if (preChapter != null) {
      showPages.addAll(preChapter.pages);
      initialPage = preChapter.pages.length;
    }
    showPages.addAll(curChapter.pages);
    // 加载下一章。
    if (curChapter.pages.length <= 1) {
      nextChapter = await bookController.loadNextChapter();
    }
    //
    if (nextChapter != null) {
      showPages.addAll(nextChapter.pages);
      if (nextChapter.pages.length == 1) {}
    }
    MyLog.d("PageModel composeChapter showPages: ${showPages.length}");
    return showPages;
  }

  refresh(ReadEvent event) async {
    _updateState(ConnectionState.waiting);
    await composeChapter(0);
    _updateState(ConnectionState.done);
  }

  Future<void> init(double viewWidth, double viewHeight) async {
    MyLog.d("PageModel init bookConfig: $bookConfig");
    bookConfig.updateSize(viewWidth, viewHeight);
    await bookController.init();
    await composeChapter(0);
  }

  void prevChapter() {
    PageState cur = curPage;
    int index = initialPage - cur.pageIndex - 1;
    MyLog.d(
        "PageModel prevChapter ${showPages.length};  index: $index; curPage:$curPage;");
    if (index >= 0) {
      //
      PageState pre = showPages[index];
      initialPage = index - pre.pageIndex;
      MyLog.d(
          "PageModel prevChapter 已在缓存中: $initialPage > ${showPages[initialPage]}");
      _updateState(ConnectionState.done);
      return;
    }
    _prevChapter(false);
  }

  nextChapter() async {
    _updateState(ConnectionState.waiting);
    PageState cur = curPage;
    MyLog.d("PageModel nextChapter curPage:$curPage");
    for (int i = cur.pageIndex; i < showPages.length; i++) {
      if (showPages[i].chapterIndex > curPage.chapterIndex) {
        // 已在缓存中。
        initialPage = i;
        MyLog.d("PageModel nextChapter 已在缓存中: $initialPage > ${showPages[i]}");
        _updateState(ConnectionState.done);
        return;
      }
    }
    // 不在缓存中。
    _nextChapter(false);
  }

  _updateState(ConnectionState state) {
    connectionState = state;
    notifyListeners();
  }

  void updatePage(int index) {
    MyLog.d("PageModel onPageChanged: ${index + 1}, ${showPages.length} ");
    initialPage = index;
    bookController.moveToChapter(curPage.chapterIndex);
    // 预加载偏移量，不足时自动加载 上下章
    int preOffset = 10;
    if (index <= preOffset) {
      _prevChapter(true);
    } else if (index >= showPages.length - 1 - preOffset) {
      _nextChapter(true);
    }
  }

  _prevChapter(bool preload) async {
    ChapterState? preChapter = await bookController.loadPreChapter();
    MyLog.i("_prevChapter: preChapter:$preChapter");
    if (preChapter != null) {
      List<PageState> pages = List.of(preChapter.pages);
      pages.addAll(showPages);
      showPages = pages;
      MyLog.i("_prevChapter: $initialPage; pages: ${preChapter.pages.length}");
      if (!preload) {
        bookController.moveSomeChapter(-1);
        initialPage = 0;
      } else {
        initialPage = initialPage + preChapter.pages.length;
      }
      _updateState(ConnectionState.done);
    }
  }

  _nextChapter(bool preload) async {
    ChapterState? nextChapter = await bookController.loadNextChapter();
    if (nextChapter != null) {
      List<PageState> pages = List.of(nextChapter.pages);
      showPages.addAll(pages);
      if (!preload) {
        bookController.moveSomeChapter(1);
        initialPage = initialPage - curPage.pageIndex + curPage.chapterSize;
      }
      _updateState(ConnectionState.done);
    }
  }

  // ----------------------

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
//
// /// UI状态控制
// class UIModel with ChangeNotifier, DiagnosticableTreeMixin {
//   bool menuVisible = false;
//
//   void showMenu() {
//     MyLog.d("ReadCache", "showMenu");
//     menuVisible = true;
//     notifyListeners();
//   }
//
//   void closeMenu() {
//     MyLog.d("ReadCache", "closeMenu");
//     menuVisible = false;
//     notifyListeners();
//   }
//
//
// }
//
// /// 页面切换数据
// class PageModel with ChangeNotifier, DiagnosticableTreeMixin {
//   PageModel(this._book) {
//     bookController.book = _book;
//   }
//
//   final Book _book;
//
//   Book get book => _book;
//
//   PageController controller = PageController();
//
//   ConnectionState connectionState = ConnectionState.done;
//
//   /// initialPage
//   int initialPage = 0;
//
//   /// 所有需要显示的页面
//   List<PageState> showPages = [];
//
//   PageState get curPage {
//     if (initialPage >= showPages.length) {
//       return PageState.empty();
//     } else {
//       return showPages[initialPage];
//     }
//   }
//
//   reload() async {
//     _updateState(ConnectionState.waiting);
//     await bookController.reload();
//     _updateState(ConnectionState.done);
//   }
//
//   ///  0: cur
//   ///  1: next
//   /// -1: prev
//   Future<List<PageState>> composeChapter(int offset) async {
//     bookController.moveSomeChapter(offset);
//     ChapterState? curChapter = await bookController.loadCurChapter();
//     ChapterState? preChapter;
//     ChapterState? nextChapter;
//     showPages.clear();
//     initialPage = 0;
//     if (curChapter == null) {
//       return showPages;
//     }
//     // --------------------------------------------------
//     // --------------------------------------------------
//     if (bookController.chapterSize <= 1) {
//       // 仅有一章，直接返回
//       showPages.addAll(curChapter.pages);
//       return showPages;
//     }
//     // 加载上一章。
//     preChapter = await bookController.loadPreChapter();
//     if (preChapter != null) {
//       showPages.addAll(preChapter.pages);
//       initialPage = preChapter.pages.length;
//     }
//     showPages.addAll(curChapter.pages);
//     // 加载下一章。
//     if (curChapter.pages.length <= 1) {
//       nextChapter = await bookController.loadNextChapter();
//     }
//     //
//     if (nextChapter != null) {
//       showPages.addAll(nextChapter.pages);
//       if(nextChapter.pages.length == 1) {
//
//       }
//     }
//     MyLog.d("PageModel composeChapter showPages: ${showPages.length}");
//     return showPages;
//   }
//
//   refresh(ReadEvent event) async {
//     _updateState(ConnectionState.waiting);
//     await composeChapter(0);
//     _updateState(ConnectionState.done);
//   }
//
//   Future<void> init(double viewWidth, double viewHeight) async {
//     MyLog.d("PageModel init bookConfig: $bookConfig");
//     bookConfig.updateSize(viewWidth, viewHeight);
//     await bookController.init();
//     await composeChapter(0);
//   }
//
//   void prevChapter() {
//     PageState cur = curPage;
//     int index = initialPage - cur.pageIndex - 1;
//     MyLog.d(
//         "PageModel prevChapter ${showPages.length};  index: $index; curPage:$curPage;");
//     if (index >= 0) {
//       //
//       PageState pre = showPages[index];
//       initialPage = index - pre.pageIndex;
//       MyLog.d(
//           "PageModel prevChapter 已在缓存中: $initialPage > ${showPages[initialPage]}");
//       _updateState(ConnectionState.done);
//       return;
//     }
//     _prevChapter(false);
//   }
//
//   nextChapter() async {
//     _updateState(ConnectionState.waiting);
//     PageState cur = curPage;
//     MyLog.d("PageModel nextChapter curPage:$curPage");
//     for (int i = cur.pageIndex; i < showPages.length; i++) {
//       if (showPages[i].chapterIndex > curPage.chapterIndex) {
//         // 已在缓存中。
//         initialPage = i;
//         MyLog.d("PageModel nextChapter 已在缓存中: $initialPage > ${showPages[i]}");
//         _updateState(ConnectionState.done);
//         return;
//       }
//     }
//     // 不在缓存中。
//     _nextChapter(false);
//   }
//
//   _updateState(ConnectionState state) {
//     connectionState = state;
//     notifyListeners();
//   }
//
//   void updatePage(int index) {
//     MyLog.d("PageModel onPageChanged: ${index + 1}, ${showPages.length} ");
//     initialPage = index;
//     bookController.moveToChapter(curPage.chapterIndex);
//     if (index == 0) {
//       _prevChapter(true);
//     } else if (index == showPages.length - 1) {
//       _nextChapter(true);
//     }
//   }
//
//   _prevChapter(bool preload) async {
//     ChapterState? preChapter = await bookController.loadPreChapter();
//     MyLog.i("_prevChapter: preChapter:$preChapter");
//     if (preChapter != null) {
//       List<PageState> pages = List.of(preChapter.pages);
//       pages.addAll(showPages);
//       showPages = pages;
//       MyLog.i("_prevChapter: $initialPage; pages: ${preChapter.pages.length}");
//       if (!preload) {
//         bookController.moveSomeChapter(-1);
//         initialPage = 0;
//       } else {
//         initialPage = initialPage + preChapter.pages.length;
//       }
//       _updateState(ConnectionState.done);
//     }
//   }
//
//   _nextChapter(bool preload) async {
//     ChapterState? nextChapter = await bookController.loadNextChapter();
//     if (nextChapter != null) {
//       List<PageState> pages = List.of(nextChapter.pages);
//       showPages.addAll(pages);
//       if (!preload) {
//         bookController.moveSomeChapter(1);
//         initialPage = initialPage - curPage.pageIndex + curPage.chapterSize;
//       }
//       _updateState(ConnectionState.done);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/pages/book_detail.dart';
import 'package:shosai/pages/book_reader.dart';
import 'package:shosai/pages/book_search.dart';
import 'package:shosai/pages/book_toc.dart';
import 'package:shosai/pages/home.dart';
import 'package:shosai/service/spider/spider.dart';
import 'package:shosai/utils/log.dart';

class AppRoutes {
  static const String _homePage = '/';
  static const String _bookReaderPage = '/book/reader/';
  static const String _bookTocPage = '/book/reader/toc';
  static const String _bookSearchPage = '/book/search/';
  static const String _bookDetailPage = '/book/detail/';
  static const String _spiderPage = '/book/service/spider/';

  /// 打开主页
  static Future<dynamic> startHomePage(BuildContext context) {
    return pushNamed(context, _homePage);
  }

  /// 打开阅读页
  static Future<dynamic> startBookReaderPage(BuildContext context, Book book) {
    return pushNamed(context, _bookReaderPage, arguments: book);
  }

  /// 打开书籍目录页
  static Future<dynamic> startBookTocPage(BuildContext context, Book book) {
    return pushNamed(context, _bookTocPage, arguments: book);
  }

  /// 打开书源爬虫页
  static Future<dynamic> startSpiderPage(
      BuildContext context, BookSource source) {
    return pushNamed(context, _spiderPage, arguments: source);
  }

  /// 打开搜索页
  static Future<dynamic> startBookSearchPage(
      BuildContext context, BookSource source) {
    return pushNamed(context, _bookSearchPage, arguments: source);
  }

  /// 书籍详情页
  static Future<dynamic> startBookDetailPage(BuildContext context, Book book) {
    return pushNamed(context, _bookDetailPage, arguments: book);
  }

  // --------------------------------------------------
  // --------------------------------------------------
  static Future<dynamic> pushNamed(
    BuildContext context,
    String name, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(name, arguments: arguments);
  }
}

/// 路由配置
class RouteConfiguration {
  /// 修改后需要重新运行应用
  static final Map<String, WidgetBuilder> _routes = {
    AppRoutes._homePage: (context) => const HomePage(),
    AppRoutes._bookReaderPage: (context) => const BookReaderPage(),
    AppRoutes._bookTocPage: (context) => BookTocPage(),
    AppRoutes._bookSearchPage: (context) => BookSearchPage(),
    AppRoutes._bookDetailPage: (context) => BookDetailPage(),
    AppRoutes._spiderPage: (context) => SpiderPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MyMaterialPageRoute<dynamic>(
      builder: (context) {
        String? routeName = settings.name;
        MyLog.d("MyMaterialPageRoute", "routeName: $routeName");
        // 统一判断一些前置条件再跳转，例如 登录状态等。
        var builder = _routes[routeName];
        MyLog.d("MyMaterialPageRoute", "builder: $builder");
        if (builder == null) {
          return const HomePage();
        } else {
          return builder(context);
        }
      },
      settings: settings,
    );
  }
}

class MyMaterialPageRoute<T> extends MaterialPageRoute<T> {
  MyMaterialPageRoute({
    required super.builder,
    super.settings,
  });

// @override
// Widget buildTransitions(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//     ) {
//   return child;
// }
}

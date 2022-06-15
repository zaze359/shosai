import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/pages/book/book_reader.dart';
import 'package:shosai/pages/home.dart';
import 'package:shosai/utils/log.dart';

class AppRoutes {
  static const String _homePage = '/';
  static const String _bookReaderPage = '/book/reader/';

  /// 打开主页
  static Future<void> pushHomePage(BuildContext context) {
    return Navigator.of(context).pushNamed(_homePage);
  }

  /// 打开阅读页
  static Future<void> pushBookReaderPage(BuildContext context, Book book) {
    MyLog.d("pushBookReaderPage", "Book: $book");
    return Navigator.of(context).pushNamed(_bookReaderPage, arguments: book);
  }
}

/// 路由配置
class RouteConfiguration {
  /// 修改后需要重新运行应用
  static final Map<String, WidgetBuilder> _routes = {
    AppRoutes._homePage: (context) => const HomePage(),
    AppRoutes._bookReaderPage: (context) => BookReaderPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MyMaterialPageRoute<void>(
      builder: (context) {
        String? routeName = settings.name;
        // 统一判断一些前置条件再跳转，例如 登录状态等。
        var builder = _routes[routeName];
        MyLog.d("MyMaterialPageRoute", "routeName: $routeName");
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

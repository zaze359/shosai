import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/pages/book_reader.dart';
import 'package:shosai/pages/book_toc.dart';
import 'package:shosai/pages/home.dart';
import 'package:shosai/utils/log.dart';

class AppRoutes {
  static const String _homePage = '/';
  static const String _bookReaderPage = '/book/reader/';
  static const String _bookTocPage = '/book/reader/toc';

  /// 打开主页
  static Future<dynamic> pushHomePage(BuildContext context) {
    return Navigator.of(context).pushNamed(_homePage);
  }

  /// 打开阅读页
  static Future<dynamic> pushBookReaderPage(BuildContext context, Book book) {
    return Navigator.of(context).pushNamed(_bookReaderPage, arguments: book);
  }

  /// 打开书籍目录页
  static Future<dynamic> pushBookTocPage(BuildContext context) {
    return Navigator.of(context).pushNamed(_bookTocPage);
  }
}

/// 路由配置
class RouteConfiguration {
  /// 修改后需要重新运行应用
  static final Map<String, WidgetBuilder> _routes = {
    AppRoutes._homePage: (context) => const HomePage(),
    // AppRoutes._bookReaderPage: (context) => BookReaderPage(),
    AppRoutes._bookReaderPage: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ReadCache()),
          ],
          child: const BookReaderPage(),
        ),
    AppRoutes._bookTocPage: (context) => BookTocPage(),
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

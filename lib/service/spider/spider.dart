import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/pages/search_bar.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/service/spider/base_rule_editor.dart';
import 'package:shosai/service/spider/content_rule_editor.dart';
import 'package:shosai/service/spider/detail_rule_editor.dart';
import 'package:shosai/service/spider/search_rule_editor.dart';
import 'package:shosai/service/spider/toc_rule_editor.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/tip.dart';

class SpiderMode extends ChangeNotifier {
  BookSource bookSource;

  TextStyle inputTextStyle = const TextStyle(fontSize: 18, color: Colors.white);

  SpiderMode(this.bookSource);

  addParam(UrlParam param) {
    bookSource.searchUrl.params.add(param);
    printD("addParam: $param");
  }

  startSearch(BuildContext context) {
    AppRoutes.startBookSearchPage(context, bookSource);
  }

  updateBookSource(BuildContext context, bookSource) {
    BookRepository().updateBookSource(bookSource).then((value) {
      this.bookSource = bookSource;
      showSnackBar(context, '书源更新成功!');
    });
  }
}

/// 书籍爬虫工具
class SpiderPage extends StatelessWidget {
  SpiderPage({Key? key}) : super(key: key);
  TextStyle tabStyle = const TextStyle(fontSize: 18, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    Map<Widget, Widget> tabMap = {
      Text(
        "基本",
        style: tabStyle,
      ): BaseRuleEditor(),
      Text(
        "搜索",
        style: tabStyle,
      ): SearchRuleEditor(),
      Text(
        "详情",
        style: tabStyle,
      ): DetailRuleEditor(),
      Text(
        "目录",
        style: tabStyle,
      ): TocRuleEditor(),
      Text(
        "正文",
        style: tabStyle,
      ): ContentRuleEditor(),
    };
    BookSource? bookSource =
        ModalRoute.of(context)?.settings.arguments as BookSource?;
    if (bookSource == null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("测试书源解析"),
          ),
          body: Text(""));
    }
    //            Theme(
    // data: ThemeData(
    // brightness: Brightness.dark,
    // primaryColor: Colors.red,
    // selectedRowColor: Colors.red,
    // iconTheme: const IconThemeData(color: Colors.teal),
    // ),)
    return ChangeNotifierProvider(
      create: (_) {
        return SpiderMode(bookSource);
      },
      builder: (context, _) {
        return DefaultTabController(
          length: tabMap.length,
          child: Scaffold(
            appBar: AppBar(
              title: SearchBar(
                hintText: '书名',
                onSubmitted: (v) {
                  context.read<SpiderMode>().startSearch(context);
                },
                enabled: false,
              ),
              actions: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).searchFieldLabel,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  onPressed: () {
                    context.read<SpiderMode>().updateBookSource(context, bookSource);
                  },
                ),
              ],
              bottom: TabBar(
                tabs: tabMap.keys.toList(),
              ),
            ),
            body: TabBarView(
              children: tabMap.values.toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<SpiderMode>().startSearch(context);
              },
              child: Icon(Icons.play_arrow),
            ),
          ),
        );
      },
    );
  }
}

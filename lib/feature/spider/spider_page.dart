import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/feature/spider/base_rule_editor.dart';
import 'package:shosai/feature/spider/content_rule_editor.dart';
import 'package:shosai/feature/spider/detail_rule_editor.dart';
import 'package:shosai/feature/spider/search_rule_editor.dart';
import 'package:shosai/feature/spider/spider_vm.dart';
import 'package:shosai/feature/spider/toc_rule_editor.dart';
import 'package:shosai/widgets/search_bar.dart';

/// 书籍爬虫工具
class SpiderPage extends StatelessWidget {
  SpiderPage({Key? key}) : super(key: key);
  TextStyle tabStyle = const TextStyle(fontSize: 18, color: Colors.white);
  late Map<Widget, Widget> tabMap = {
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

  @override
  Widget build(BuildContext context) {
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
              title: BookSearchBar(
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
                    context
                        .read<SpiderMode>()
                        .updateBookSource(context, bookSource);
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

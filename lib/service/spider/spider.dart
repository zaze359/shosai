import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/pages/search_bar.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/http/http.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/request_args_layout.dart';

class _SpiderMode extends ChangeNotifier {
  BookSource bookSource;

  TextStyle inputTextStyle = const TextStyle(fontSize: 18, color: Colors.white);

  _SpiderMode(this.bookSource);

  addParam(UrlParam param) {
    bookSource.searchUrl.params.add(param);
    printD("addParam: $param");
  }

  startSearch(BuildContext context) {
    AppRoutes.startBookSearchPage(context, bookSource);
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
      ): _BookSourceInfo(),
      Text(
        "搜索",
        style: tabStyle,
      ): _BookSearchInfo(),
      Text(
        "详情",
        style: tabStyle,
      ): _BookDetailInfo(),
      Text(
        "目录",
        style: tabStyle,
      ): _BookToc(),
      Text(
        "正文",
        style: tabStyle,
      ): _BookContent(),
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
        return _SpiderMode(bookSource);
      },
      builder: (context, _) {
        return DefaultTabController(
          length: tabMap.length,
          child: Scaffold(
            appBar: AppBar(
              title: SearchBar(
                hintText: '书名',
                onSubmitted: (v) {
                  context.read<_SpiderMode>().startSearch(context);
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
                    BookRepository().updateBookSource(bookSource);
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
                context.read<_SpiderMode>().startSearch(context);
              },
              child: Icon(Icons.play_arrow),
            ),
          ),
        );
      },
    );
  }
}

// 书源信息
class _BookSourceInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "地址",
                    hintText: "https://www.xxx.com",
                  ),
                  initialValue: bookSource.url,
                  validator: (value) {
                    return value!.trim().isNotEmpty ? null : "书源地址不能为空";
                  },
                  onChanged: (value) {
                    bookSource.url = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "名称",
                  ),
                  initialValue: bookSource.name,
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "书源名称不能为空";
                  },
                  onChanged: (value) {
                    bookSource.name = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "描述",
                  ),
                  initialValue: bookSource.comment,
                  onChanged: (value) {
                    bookSource.comment = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分组",
                    hintText: "玄幻",
                  ),
                  initialValue: bookSource.tags,
                  onChanged: (value) {
                    bookSource.tags = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 搜索
class _BookSearchInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        SearchRule rule = bookSource.searchRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "搜索地址",
                    hintText: "相对或绝对路径",
                  ),
                  initialValue: bookSource.searchUrl.path ?? "",
                  onChanged: (value) {
                    bookSource.searchUrl.path = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书籍列表规则",
                  ),
                  initialValue: rule.bookList.rule ?? "",
                  onChanged: (value) {
                    rule.bookList.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书名规则",
                  ),
                  initialValue: rule.name.rule ?? "",
                  onChanged: (value) {
                    rule.name.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "作者规则",
                  ),
                  initialValue: rule.author.rule ?? "",
                  onChanged: (value) {
                    rule.author.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "封面规则",
                  ),
                  initialValue: rule.coverUrl.rule ?? "",
                  onChanged: (value) {
                    rule.coverUrl.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "简介规则",
                  ),
                  initialValue: rule.intro.rule ?? "",
                  onChanged: (value) {
                    rule.intro.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分类规则",
                  ),
                  initialValue: rule.tags.rule ?? "",
                  onChanged: (value) {
                    rule.tags.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "字数规则",
                  ),
                  initialValue: rule.wordCount.rule ?? "",
                  onChanged: (value) {
                    rule.wordCount.rule = value;
                  },
                ),
                RequestArgsWidget(bookSource.searchUrl.params, mode.addParam),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 书籍详情
class _BookDetailInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        BookInfoRule rule = bookSource.bookInfoRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书名规则",
                  ),
                  initialValue: rule.name.rule ?? "",
                  onChanged: (value) {
                    rule.name.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "作者规则",
                  ),
                  initialValue: rule.author.rule ?? "",
                  onChanged: (value) {
                    rule.author.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "封面规则",
                  ),
                  initialValue: rule.coverUrl.rule ?? "",
                  onChanged: (value) {
                    rule.coverUrl.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "简介规则",
                  ),
                  initialValue: rule.intro.rule ?? "",
                  onChanged: (value) {
                    rule.intro.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分类规则",
                  ),
                  initialValue: rule.tags.rule ?? "",
                  onChanged: (value) {
                    rule.tags.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "目录URL规则",
                  ),
                  initialValue: rule.tocUrl.rule ?? "",
                  onChanged: (value) {
                    rule.tocUrl.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "字数规则",
                  ),
                  initialValue: rule.wordCount.rule ?? "",
                  onChanged: (value) {
                    rule.wordCount.rule = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 书籍目录规则
class _BookToc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        TocRule rule = bookSource.tocRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "目录列表规则",
                  ),
                  initialValue: rule.chapterList.rule ?? "",
                  onChanged: (value) {
                    rule.chapterList.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "章节名规则",
                  ),
                  initialValue: rule.chapterName.rule ?? "",
                  onChanged: (value) {
                    rule.chapterName.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "章节URL规则",
                  ),
                  initialValue: rule.chapterUrl.rule ?? "",
                  onChanged: (value) {
                    rule.chapterUrl.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "更新时间",
                  ),
                  initialValue: rule.updateTime.rule ?? "",
                  onChanged: (value) {
                    rule.updateTime.rule = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 正文
class _BookContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        ContentRule rule = bookSource.contentRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "正文规则",
                  ),
                  initialValue: rule.content.rule ?? "",
                  onChanged: (value) {
                    rule.content.rule = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

///
class _MyTextFormField extends StatelessWidget {
  String? initialValue;
  InputDecoration? decoration;
  ValueChanged<String>? onChanged;
  FormFieldValidator<String>? validator;

  _MyTextFormField(
      {this.initialValue, this.decoration, this.onChanged, this.validator});

  // ?.characters.join('\u{200B}')
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      maxLines: 10,
      minLines: 1,
      decoration: InputDecoration(
        labelText: decoration?.labelText,
        labelStyle: const TextStyle(color: Colors.red),
        hintText: decoration?.hintText,
        hintStyle: decoration?.hintStyle,
        hintMaxLines: decoration?.hintMaxLines,
      ),
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
